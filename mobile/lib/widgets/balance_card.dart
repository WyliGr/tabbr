import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/balance.dart';
import '../providers/expense_provider.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.balance.entries.isEmpty) {
          return const _BalanceLoading();
        }
        if (provider.balance.entries.isEmpty) {
          return const _AllSettled();
        }

        final entries = provider.balance.entries;
        // Calculate net flow: positive = you are owed, negative = you owe
        // For the summary we aggregate by person to build the progress bar
        final memberTotals = <String, double>{};
        for (final e in entries) {
          // toPerson is owed, fromPerson owes
          memberTotals[e.toPersonName] =
              (memberTotals[e.toPersonName] ?? 0) + e.amount;
          memberTotals[e.fromPersonName] =
              (memberTotals[e.fromPersonName] ?? 0) - e.amount;
        }
        final totalOwed = entries.fold<double>(0, (sum, e) => sum + e.amount);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          children: [
            // ── Balance summary card ──
            _BalanceSummary(
              totalOwed: totalOwed,
              memberTotals: memberTotals,
              entryCount: entries.length,
            ),
            const SizedBox(height: 20),
            // ── Section label ──
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 8),
              child: Text(
                'SETTLEMENTS',
                style: AppTheme.monoLabel(
                  fontSize: 9,
                  color: AppColors.of(context).inkMuted,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            // ── Balance entries as bordered rows ──
            for (int i = 0; i < entries.length; i++)
              _BalanceRow(
                key: ValueKey('${entries[i].fromPerson}-${entries[i].toPerson}'),
                entry: entries[i],
                showBottomBorder: i < entries.length - 1,
              ),
          ],
        );
      },
    );
  }
}

/// ── Balance summary card with mini progress bar ──────────────
class _BalanceSummary extends StatelessWidget {
  final double totalOwed;
  final Map<String, double> memberTotals;
  final int entryCount;

  const _BalanceSummary({
    required this.totalOwed,
    required this.memberTotals,
    required this.entryCount,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final currency = NumberFormat.currency(symbol: '\u20AC', decimalDigits: 2);

    // Build sorted list of members by absolute amount for progress bar
    final sortedMembers = memberTotals.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    // Total for proportional split
    final absSum = sortedMembers.fold<double>(0, (s, e) => s + e.value.abs());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: c.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Label ──
          Text(
            'YOUR BALANCE',
            style: AppTheme.monoLabel(
              fontSize: 9,
              color: c.inkMuted,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 6),
          // ── Big amount ──
          Text(
            '+${currency.format(totalOwed)}',
            style: AppTheme.mono(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: c.positive,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          // ── Sublabel ──
          Text(
            'across $entryCount settlement${entryCount == 1 ? '' : 's'}',
            style: TextStyle(
              color: c.inkMuted,
              fontSize: 12,
            ),
          ),
          // ── Mini progress bar ──
          if (sortedMembers.isNotEmpty && absSum > 0) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                height: 4,
                child: Row(
                  children: sortedMembers.map((e) {
                    final fraction = (e.value.abs() / absSum).clamp(0.0, 1.0);
                    final isOwed = e.value > 0;
                    return Expanded(
                      flex: (fraction * 1000).round().clamp(1, 1000),
                      child: Container(
                        color: isOwed
                            ? AppTheme.avatarColor(e.key.hashCode)
                            : AppTheme.avatarColor(e.key.hashCode)
                                .withValues(alpha: 0.35),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // ── Member split legend ──
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: sortedMembers.take(4).map((e) {
                final isOwed = e.value > 0;
                final pct = absSum > 0
                    ? ((e.value.abs() / absSum) * 100).round()
                    : 0;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isOwed
                            ? AppTheme.avatarColor(e.key.hashCode)
                            : AppTheme.avatarColor(e.key.hashCode)
                                .withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      e.key,
                      style: TextStyle(
                        color: c.inkSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$pct%',
                      style: AppTheme.mono(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: c.inkMuted,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// ── All settled empty state ───────────────────────────────────
class _AllSettled extends StatelessWidget {
  const _AllSettled();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.positiveSoft,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 28,
                      color: c.positive,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'All settled up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: c.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No outstanding balances',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: c.inkSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ── Loading state ─────────────────────────────────────────────
class _BalanceLoading extends StatelessWidget {
  const _BalanceLoading();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: c.surfaceDim,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
          ),
          const SizedBox(height: 20),
          for (int i = 0; i < 3; i++)
            Container(
              height: 44,
              margin: const EdgeInsets.only(bottom: 1),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: i < 2 ? c.border : Colors.transparent,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ── Balance row: "A owes B  $12.40" (bordered, not card) ─────
class _BalanceRow extends StatelessWidget {
  final BalanceEntry entry;
  final bool showBottomBorder;

  const _BalanceRow({
    super.key,
    required this.entry,
    required this.showBottomBorder,
  });

  String _initial(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final currency = NumberFormat.currency(symbol: '', decimalDigits: 2);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: showBottomBorder ? c.border : Colors.transparent,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          // ── "Owes" avatar (circle, grey) ──
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: c.surfaceDim,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _initial(entry.fromPersonName),
                style: TextStyle(
                  color: c.inkSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // ── Arrow ──
          Icon(
            Icons.arrow_forward_rounded,
            size: 14,
            color: c.inkMuted,
          ),
          const SizedBox(width: 8),
          // ── "Owed" avatar (circle, accent) ──
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.avatarColor(entry.toPerson),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _initial(entry.toPersonName),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // ── Names ──
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: entry.fromPersonName,
                    style: TextStyle(
                      color: c.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' owes ',
                    style: TextStyle(
                      color: c.inkMuted,
                      fontSize: 13,
                    ),
                  ),
                  TextSpan(
                    text: entry.toPersonName,
                    style: TextStyle(
                      color: c.inkSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Amount (mono) ──
          Text(
            currency.format(entry.amount),
            style: AppTheme.mono(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.positive,
            ).copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}