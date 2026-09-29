#!/usr/bin/env python3
"""Authoritative dependency audit against the OSV vulnerability database.

Queries https://api.osv.dev/v1/querybatch for every pinned dependency and
reports, per vulnerability: package, installed version, severity and the
first fixed version.

Usage:
    python scripts/osv_audit.py backend/requirements.txt
    python scripts/osv_audit.py mobile/pubspec.lock

Exit code is 1 when at least one vulnerability is found, 0 otherwise, so the
script can be used as a CI gate.

Only the Python standard library is required.
"""

from __future__ import annotations

import json
import re
import sys
import urllib.request

OSV_BATCH_URL = "https://api.osv.dev/v1/querybatch"
OSV_VULN_URL = "https://osv.dev/vulnerability/"
OSV_DETAIL_URL = "https://api.osv.dev/v1/vulns/"

# OSV severity strings, ordered from most to least severe.
SEVERITY_ORDER = ["CRITICAL", "HIGH", "MODERATE", "MEDIUM", "LOW", "UNKNOWN"]


def _post(url: str, payload: dict, timeout: int = 60) -> dict:
    request = urllib.request.Request(
        url,
        data=json.dumps(payload).encode(),
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(request, timeout=timeout) as response:
        return json.load(response)


def _get(url: str, timeout: int = 60) -> dict:
    request = urllib.request.Request(url, headers={"Accept": "application/json"})
    with urllib.request.urlopen(request, timeout=timeout) as response:
        return json.load(response)


def parse_requirements(path: str) -> dict[str, str]:
    """Return {package: version} from a pinned pip requirements file."""
    packages: dict[str, str] = {}
    with open(path, encoding="utf-8") as handle:
        for raw_line in handle:
            line = raw_line.split("#", 1)[0].strip()
            if not line:
                continue
            # Strip environment markers, e.g. `; python_version < "3.12"`.
            line = line.split(";", 1)[0].strip()
            # Strip extras, e.g. `uvicorn[standard]==0.54.0`.
            line = re.sub(r"\[[^\]]*\]", "", line)
            for match in re.finditer(r"([A-Za-z0-9._-]+)==([^\s,]+)", line):
                packages[match.group(1)] = match.group(2)
    return packages


def parse_pubspec_lock(path: str) -> dict[str, str]:
    """Return {package: version} from a Flutter/Dart pubspec.lock file."""
    packages: dict[str, str] = {}
    current: str | None = None
    with open(path, encoding="utf-8") as handle:
        for line in handle:
            header = re.match(r"^  ([a-z0-9_]+):\s*$", line)
            if header:
                current = header.group(1)
                continue
            version = re.match(r'^    version:\s*"?([^"\s]+)"?\s*$', line)
            if version and current:
                # SDK-vendored packages are reported as "0.0.0" — skip them.
                if version.group(1) != "0.0.0":
                    packages[current] = version.group(1)
    return packages


def severity_of(vuln: dict) -> str:
    """Best-effort severity from an OSV record."""
    database_specific = vuln.get("database_specific") or {}
    severity = database_specific.get("severity")
    if isinstance(severity, str) and severity:
        return severity.upper()
    for entry in vuln.get("severity") or []:
        if entry.get("type") == "CVSS_V3":
            score = entry.get("score", "")
            match = re.search(r"/(\d\.\d)$", score)
            if match:
                return _score_to_severity(float(match.group(1)))
    # GitHub advisories expose the severity through the aliases/ecosystem.
    for entry in vuln.get("affected") or []:
        entry_severity = (entry.get("database_specific") or {}).get("severity")
        if isinstance(entry_severity, str) and entry_severity:
            return entry_severity.upper()
    return "UNKNOWN"


def _score_to_severity(score: float) -> str:
    if score >= 9.0:
        return "CRITICAL"
    if score >= 7.0:
        return "HIGH"
    if score >= 4.0:
        return "MODERATE"
    if score > 0.0:
        return "LOW"
    return "UNKNOWN"


def fixed_versions(vuln: dict) -> list[str]:
    """Return the 'fixed' version of every affected range in an OSV record."""
    fixed: list[str] = []
    for affected in vuln.get("affected") or []:
        for range_entry in affected.get("ranges") or []:
            for event in range_entry.get("events") or []:
                if "fixed" in event:
                    value = event["fixed"]
                    # Git-commit style fixes are not release versions.
                    if len(value) != 40:
                        fixed.append(value)
    return sorted(set(fixed))


def audit(packages: dict[str, str], ecosystem: str) -> list[dict]:
    names = list(packages)
    queries = [
        {"package": {"name": name, "ecosystem": ecosystem}, "version": packages[name]}
        for name in names
    ]
    found: list[tuple[str, str]] = []
    # OSV accepts large batches, but keep the payload reasonable.
    for start in range(0, len(queries), 100):
        chunk = queries[start : start + 100]
        response = _post(OSV_BATCH_URL, {"queries": chunk})
        for name, result in zip(names[start : start + 100], response.get("results", [])):
            for vuln in result.get("vulns", []):
                found.append((name, vuln.get("id", "?")))

    # querybatch only returns abbreviated records (id + modified), so fetch the
    # full record for each distinct advisory to get severity / fixed versions.
    details: dict[str, dict] = {}
    for _, vuln_id in found:
        if vuln_id not in details:
            try:
                details[vuln_id] = _get(OSV_DETAIL_URL + vuln_id)
            except Exception:  # noqa: BLE001 - network hiccup must not abort
                details[vuln_id] = {}

    results: list[dict] = []
    for name, vuln_id in found:
        vuln = details.get(vuln_id) or {}
        results.append(
            {
                "package": name,
                "installed": packages[name],
                "id": vuln_id,
                "aliases": vuln.get("aliases", []),
                "severity": severity_of(vuln),
                "summary": vuln.get("summary", ""),
                "fixed": fixed_versions(vuln),
                "url": OSV_VULN_URL + vuln_id,
            }
        )
    results.sort(
        key=lambda item: (SEVERITY_ORDER.index(item["severity"])
                          if item["severity"] in SEVERITY_ORDER else 99)
    )
    return results


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        print(__doc__)
        return 2

    path = argv[1]
    if path.endswith(".lock"):
        packages = parse_pubspec_lock(path)
        ecosystem = "Pub"
    else:
        packages = parse_requirements(path)
        ecosystem = "PyPI"

    print(f"Auditing {len(packages)} pinned {ecosystem} packages from {path}")
    findings = audit(packages, ecosystem)

    if not findings:
        print("No known vulnerabilities. All pinned versions are clean in OSV.")
        return 0

    print(f"\n{len(findings)} vulnerabilities found:\n")
    for finding in findings:
        fixed = ", ".join(finding["fixed"]) or "no fix released"
        aliases = f" ({', '.join(finding['aliases'])})" if finding["aliases"] else ""
        print(
            f"[{finding['severity']:8}] {finding['package']}=={finding['installed']} "
            f"-> fixed in {fixed}\n"
            f"           {finding['id']}{aliases} {finding['url']}\n"
            f"           {finding['summary']}\n"
        )
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
