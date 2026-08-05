import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/balance.dart';
import '../providers/expense_provider.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.balance.entries.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.balance.entries.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.savings_rounded,
                    size: 56,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'All settled up',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No outstanding balances',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: provider.balance.entries.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final entry = provider.balance.entries[index];
            return _BalanceTile(entry: entry);
          },
        );
      },
    );
  }
}

class _BalanceTile extends StatelessWidget {
  final BalanceEntry entry;

  const _BalanceTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '', decimalDigits: 2);
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(
              Icons.arrow_forward_rounded,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.fromPersonName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'owes ${entry.toPersonName}',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            currency.format(entry.amount),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
