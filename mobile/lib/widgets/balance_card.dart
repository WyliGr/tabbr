import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/balance.dart';
import '../providers/expense_provider.dart';

/// Design tokens (kept local so widgets render correctly regardless of theme).
class _T {
  static const surface = Color(0xFF1A1D24);
  static const primary = Color(0xFF7C5CFC);
  static const primaryBlue = Color(0xFF5B8DEF);
  static const positive = Color(0xFF2DD4A7);
  static const negative = Color(0xFFFF6B6B);
  static const textPrimary = Color(0xFFF5F7FA);
  static const textSecondary = Color(0xFF8B92A5);
  static const textMuted = Color(0xFF5C6378);
}

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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: provider.balance.entries.length,
          itemBuilder: (context, index) {
            final entry = provider.balance.entries[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BalanceTile(
                key: ValueKey('${entry.fromPerson}-${entry.toPerson}'),
                entry: entry,
                index: index,
              ),
            );
          },
        );
      },
    );
  }
}

class _AllSettled extends StatelessWidget {
  const _AllSettled();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _T.positive.withValues(alpha: 0.12),
                    border: Border.all(
                      color: _T.positive.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 44,
                    color: _T.positive,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'All settled up',
                  style: TextStyle(
                    color: _T.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'No outstanding balances between\nmembers of this room',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _T.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BalanceLoading extends StatelessWidget {
  const _BalanceLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: _T.surface,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class _BalanceTile extends StatelessWidget {
  final BalanceEntry entry;
  final int index;

  const _BalanceTile({
    super.key,
    required this.entry,
    required this.index,
  });

  Color _avatarColor() {
    final colors = [
      _T.primary,
      _T.primaryBlue,
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
      _T.negative,
      _T.positive,
    ];
    return colors[entry.fromPerson.abs() % colors.length];
  }

  String _initial(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '', decimalDigits: 2);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar of the person who owes
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _avatarColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _initial(entry.fromPersonName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Names + "owes"
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            entry.fromPersonName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _T.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            'owes',
                            style: TextStyle(
                              color: _T.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: _T.textMuted,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        entry.toPersonName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _T.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Amount
              Text(
                currency.format(entry.amount),
                style: const TextStyle(
                  color: _T.positive,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}