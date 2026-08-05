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
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          itemCount: provider.balance.entries.length,
          itemBuilder: (context, index) {
            final entry = provider.balance.entries[index];
            return _BalanceTile(
              key: ValueKey('${entry.fromPerson}-${entry.toPerson}'),
              entry: entry,
            );
          },
        );
      },
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
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.positiveSoft,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 32,
                      color: c.positive,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'All settled up',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: c.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'No outstanding balances\nbetween members',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: c.inkSecondary,
                      fontSize: 14,
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
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: c.surfaceDim,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
      ),
    );
  }
}

/// ── Balance tile: "A owes B  $12.40" ──────────────────────────
class _BalanceTile extends StatelessWidget {
  final BalanceEntry entry;

  const _BalanceTile({super.key, required this.entry});

  String _initial(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final currency = NumberFormat.currency(symbol: '', decimalDigits: 2);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: c.border, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            // ── "Owes" avatar ──
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.avatarColor(entry.fromPerson),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Center(
                child: Text(
                  _initial(entry.fromPersonName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: ' owes ',
                      style: TextStyle(
                        color: c.inkMuted,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: entry.toPersonName,
                      style: TextStyle(
                        color: c.inkSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // ── Amount ──
            Text(
              currency.format(entry.amount),
              style: TextStyle(
                color: c.positive,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}