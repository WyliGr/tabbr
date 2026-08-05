import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';

/// Design tokens (kept local so widgets render correctly regardless of theme).
class _T {
  static const surface = Color(0xFF1A1D24);
  static const surfaceElevated = Color(0xFF22262E);
  static const primary = Color(0xFF7C5CFC);
  static const primaryBlue = Color(0xFF5B8DEF);
  static const negative = Color(0xFFFF6B6B);
  static const textPrimary = Color(0xFFF5F7FA);
  static const textSecondary = Color(0xFF8B92A5);
  static const textMuted = Color(0xFF5C6378);
}

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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ExpenseTile(
                key: ValueKey(expense.id),
                expense: expense,
                index: index,
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyExpenses extends StatelessWidget {
  const _EmptyExpenses();

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
                    color: _T.primary.withValues(alpha: 0.12),
                    border: Border.all(
                      color: _T.primary.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    size: 40,
                    color: _T.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No expenses yet',
                  style: TextStyle(
                    color: _T.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add your first expense to start\nsplitting with friends',
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
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: 5,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = Curves.easeInOut.transform(_controller.value);
            return Opacity(opacity: 0.35 + 0.4 * t, child: child);
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: _T.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _T.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 14,
                          width: 140,
                          decoration: BoxDecoration(
                            color: _T.surfaceElevated,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 10,
                          width: 100,
                          decoration: BoxDecoration(
                            color: _T.surfaceElevated,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final int index;

  const _ExpenseTile({
    super.key,
    required this.expense,
    required this.index,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _T.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Delete expense?',
          style: TextStyle(
            color: _T.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Delete "${expense.description}"? This cannot be undone.',
          style: const TextStyle(color: _T.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: _T.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: _T.negative),
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
    final currency = NumberFormat.currency(symbol: '', decimalDigits: 2);
    final dateFormat = DateFormat('MMM d, y');

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
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onLongPress: () => _confirmDelete(context),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Leading category icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_T.primary, _T.primaryBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _T.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${expense.payerName} • ${dateFormat.format(expense.date.toLocal())}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _T.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Amount
                  Text(
                    currency.format(expense.amount),
                    style: const TextStyle(
                      color: _T.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Subtle delete
                  GestureDetector(
                    onTap: () => _confirmDelete(context),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: _T.textMuted,
                      ),
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