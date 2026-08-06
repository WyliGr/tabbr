import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/api_config.dart';
import '../config/theme.dart';
import '../services/api_service.dart';

/// Hosted Tabbr Cloud endpoint. One-tap connect: no URL to type.
const String kTabbrCloudUrl = 'https://cloud.tabbr.app';

class ServerSetupScreen extends StatefulWidget {
  const ServerSetupScreen({super.key});

  @override
  State<ServerSetupScreen> createState() => _ServerSetupScreenState();
}

class _ServerSetupScreenState extends State<ServerSetupScreen> {
  late final TextEditingController _controller;

  /// Which option is currently expanded. `null` = neither (shows the two
  /// cards collapsed). `true` = Cloud, `false` = Self-Hosted.
  bool? _expanded;

  bool _testing = false;
  bool _saving = false;
  String? _status;
  bool _statusOk = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<ApiConfig>().serverUrl,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Cloud one-tap connect ───────────────────────────────────────
  Future<void> _connectCloud() async {
    setState(() {
      _saving = true;
      _status = null;
    });
    final config = context.read<ApiConfig>();
    final api = ApiService(config);
    await config.setServerUrl(kTabbrCloudUrl);
    final ok = await api.testConnection();
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _status =
            'Could not reach Tabbr Cloud. Check your internet connection.';
        _statusOk = false;
      });
    }
  }

  // ── Existing test / save (Self-Hosted flow) ─────────────────────
  Future<void> _test() async {
    setState(() {
      _testing = true;
      _status = null;
    });
    final config = context.read<ApiConfig>();
    final api = ApiService(config);
    final url = _controller.text.trim();
    if (url.isEmpty) {
      setState(() {
        _testing = false;
        _status = 'Please enter a server URL';
        _statusOk = false;
      });
      return;
    }
    await config.setServerUrl(url);
    final ok = await api.testConnection();
    if (!mounted) return;
    setState(() {
      _testing = false;
      _status = ok
          ? 'Connected successfully'
          : 'Could not reach the server. Check the URL and try again.';
      _statusOk = ok;
    });
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _status = null;
    });
    final config = context.read<ApiConfig>();
    final api = ApiService(config);
    final url = _controller.text.trim();
    if (url.isEmpty) {
      setState(() {
        _saving = false;
        _status = 'Please enter a server URL';
        _statusOk = false;
      });
      return;
    }
    await config.setServerUrl(url);
    final ok = await api.testConnection();
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _status = 'Could not reach the server. Check the URL and try again.';
        _statusOk = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // ── Icon ──
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: c.accentSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.hub_rounded,
                    size: 30,
                    color: c.accent,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Connect to server',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: c.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose how to connect to Tabbr',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: c.inkSecondary,
                ),
              ),
              const SizedBox(height: 28),

              // ── Cloud card (primary / recommended) ──
              _CloudCard(
                expanded: _expanded == true,
                saving: _saving,
                status: _expanded == true ? _status : null,
                statusOk: _statusOk,
                onTap: _saving
                    ? null
                    : () {
                        setState(() {
                          _expanded = true;
                          _status = null;
                        });
                      },
                onConnect: _saving ? null : _connectCloud,
              ),
              const SizedBox(height: 12),

              // ── Self-Hosted card (secondary) ──
              _SelfHostedCard(
                expanded: _expanded == false,
                controller: _controller,
                testing: _testing,
                saving: _saving,
                status: _expanded == false ? _status : null,
                statusOk: _statusOk,
                onTap: _saving || _testing
                    ? null
                    : () {
                        setState(() {
                          _expanded = false;
                          _status = null;
                        });
                      },
                onTest: _saving || _testing ? null : _test,
                onSave: _saving || _testing ? null : _save,
              ),

              const Spacer(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//  Cloud card — one-tap connect to the hosted Tabbr instance.
//  Shown first, slightly more prominent (accent border + tint).
// ──────────────────────────────────────────────────────────────────
class _CloudCard extends StatelessWidget {
  final bool expanded;
  final bool saving;
  final String? status;
  final bool statusOk;
  final VoidCallback? onTap;
  final VoidCallback? onConnect;

  const _CloudCard({
    required this.expanded,
    required this.saving,
    required this.status,
    required this.statusOk,
    required this.onTap,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Material(
      color: c.accentSurface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: expanded ? c.accentBorder : c.border,
              width: expanded ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c.accentSoft,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Icon(
                      Icons.cloud_rounded,
                      size: 22,
                      color: c.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Tabbr Cloud',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: c.ink,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // small "tabbr cloud" badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: c.accentSoft,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusSm),
                                border: Border.all(
                                  color: c.accentBorder,
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                'RECOMMENDED',
                                style: AppTheme.monoLabel(
                                  fontSize: 8,
                                  color: c.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'One-tap connect · Hosted by Tabbr',
                          style: TextStyle(
                            fontSize: 12,
                            color: c.inkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: c.inkSecondary,
                    size: 22,
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: expanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Host endpoint, mono, as a hint
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: c.surface,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusMd),
                                border: Border.all(color: c.border, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.link_rounded,
                                    size: 14,
                                    color: c.inkSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      kTabbrCloudUrl,
                                      style: AppTheme.mono(
                                        fontSize: 12,
                                        color: c.ink,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (status != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      statusOk
                                          ? Icons.check_circle_rounded
                                          : Icons.error_outline_rounded,
                                      color:
                                          statusOk ? c.positive : c.negative,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        status!,
                                        style: TextStyle(
                                          color: statusOk
                                              ? c.positive
                                              : c.negative,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 12),
                            // Connect button (ink filled)
                            Opacity(
                              opacity: saving ? 0.6 : 1.0,
                              child: Material(
                                color: c.ink,
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMd),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMd),
                                  onTap: onConnect,
                                  child: Container(
                                    height: 46,
                                    alignment: Alignment.center,
                                    child: saving
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: c.background,
                                            ),
                                          )
                                        : Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.bolt_rounded,
                                                size: 16,
                                                color: c.background,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Connect to Tabbr Cloud',
                                                style: TextStyle(
                                                  color: c.background,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//  Self-Hosted card — existing URL input flow, collapsed by default.
// ──────────────────────────────────────────────────────────────────
class _SelfHostedCard extends StatelessWidget {
  final bool expanded;
  final TextEditingController controller;
  final bool testing;
  final bool saving;
  final String? status;
  final bool statusOk;
  final VoidCallback? onTap;
  final VoidCallback? onTest;
  final VoidCallback? onSave;

  const _SelfHostedCard({
    required this.expanded,
    required this.controller,
    required this.testing,
    required this.saving,
    required this.status,
    required this.statusOk,
    required this.onTap,
    required this.onTest,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: expanded ? c.accentBorder : c.border,
              width: expanded ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c.surfaceDim,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Icon(
                      Icons.dns_rounded,
                      size: 22,
                      color: c.ink,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Self-Hosted',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: c.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Enter your own server URL',
                          style: TextStyle(
                            fontSize: 12,
                            color: c.inkSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: c.inkSecondary,
                    size: 22,
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: expanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: controller,
                              keyboardType: TextInputType.url,
                              autocorrect: false,
                              style: TextStyle(color: c.ink, fontSize: 14),
                              decoration: const InputDecoration(
                                labelText: 'Server URL',
                                hintText: 'http://localhost:8000',
                              ),
                            ),
                            if (status != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      statusOk
                                          ? Icons.check_circle_rounded
                                          : Icons.error_outline_rounded,
                                      color:
                                          statusOk ? c.positive : c.negative,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        status!,
                                        style: TextStyle(
                                          color: statusOk
                                              ? c.positive
                                              : c.negative,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 12),
                            // Save button (ink filled)
                            Opacity(
                              opacity: saving || testing ? 0.6 : 1.0,
                              child: Material(
                                color: c.ink,
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMd),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMd),
                                  onTap: onSave,
                                  child: Container(
                                    height: 46,
                                    alignment: Alignment.center,
                                    child: saving
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: c.background,
                                            ),
                                          )
                                        : Text(
                                            'Save and continue',
                                            style: TextStyle(
                                              color: c.background,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Test button (outlined)
                            SizedBox(
                              height: 46,
                              child: OutlinedButton(
                                onPressed: onTest,
                                child: testing
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Test connection'),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}