import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class ExpenseList extends StatelessWidget {
  const ExpenseList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.expenses.isEmpty) {
          return const _LoadingList();
        }
        if (provider.expenses.isEmpty) {
          return const _EmptyExpenses();
        }

        final expenses = provider.expenses;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            final isLast = index == expenses.length - 1;
            return _ExpenseRow(
              key: ValueKey(expense.id),
              expense: expense,
              showBottomBorder: !isLast,
            );
          },
        );
      },
    );
  }
}

/// ── Empty state ───────────────────────────────────────────────
class _EmptyExpenses extends StatelessWidget {
  const _EmptyExpenses();

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
                      color: c.accentSoft,
                    ),
                    child: Icon(
                      Icons.receipt_outlined,
                      size: 26,
                      color: c.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No expenses yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: c.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap + to add your first expense',
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

/// ── Loading shimmer ───────────────────────────────────────────
class _LoadingList extends StatefulWidget {
  const _LoadingList();

  @override
  State<_LoadingList> createState() => _LoadingListState();
}

class _LoadingListState extends State<_LoadingList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = Curves.easeInOut.transform(_controller.value);
            return Opacity(opacity: 0.3 + 0.4 * t, child: child);
          },
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: index < 5 ? c.border : Colors.transparent,
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: c.surfaceDim,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: c.surfaceDim,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 56,
                  height: 14,
                  decoration: BoxDecoration(
                    color: c.surfaceDim,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ── Expense row (bordered, not card) ──────────────────────────
class _ExpenseRow extends StatelessWidget {
  final Expense expense;
  final bool showBottomBorder;

  const _ExpenseRow({
    super.key,
    required this.expense,
    required this.showBottomBorder,
  });

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final c = AppColors.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete expense?'),
        content: Text('Delete "${expense.description}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: c.negative),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final ok = await context.read<ExpenseProvider>().deleteExpense(expense.id);
      if (!context.mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<ExpenseProvider>().errorMessage ?? 'Failed to delete',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final currency = NumberFormat.currency(symbol: '', decimalDigits: 2);
    final dateFormat = DateFormat('MMM d');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _confirmDelete(context),
        onLongPress: () => _confirmDelete(context),
        child: Container(
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
              // ── Payer avatar (circle) ──
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.avatarColor(expense.payerId),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _initials(expense.payerName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // ── Description + meta ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: c.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${expense.payerName} paid · ${dateFormat.format(expense.date.toLocal())}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.mono(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: c.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // ── Amount (mono, semibold) ──
              Text(
                currency.format(expense.amount),
                style: AppTheme.mono(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: c.ink,
                ).copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}