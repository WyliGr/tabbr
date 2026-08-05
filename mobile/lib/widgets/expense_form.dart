import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/member.dart';
import '../providers/expense_provider.dart';

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({super.key});

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _amountFocus = FocusNode();

  int? _payerId;
  DateTime _date = DateTime.now();
  bool _submitting = false;
  String? _submitError;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppTheme.accent,
                onPrimary: AppTheme.background,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_payerId == null) {
      setState(() => _submitError = 'Please choose who paid');
      return;
    }
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    final amount = double.parse(_amountController.text.replaceAll(',', '.'));
    final description = _descriptionController.text.trim();
    final provider = context.read<ExpenseProvider>();
    final ok = await provider.addExpense(
      amount: amount,
      description: description,
      payerId: _payerId!,
      date: _date,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _submitting = false;
        _submitError = provider.errorMessage ?? 'Failed to add expense';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = context.watch<ExpenseProvider>().members;
    final dateFormat = DateFormat('MMM d, y');

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Drag handle ──
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.borderStrong,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // ── Title ──
                const Text(
                  'New expense',
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Amount (hero input) ──
                const Text(
                  'AMOUNT',
                  style: TextStyle(
                    color: AppTheme.inkMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDim,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Row(
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Text(
                        '\u20AC',
                        style: TextStyle(
                          color: AppTheme.inkMuted,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextFormField(
                          controller: _amountController,
                          focusNode: _amountFocus,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          autofocus: true,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: AppTheme.ink,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                            height: 1.4,
                          ),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: const TextStyle(
                              color: AppTheme.inkMuted,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.0,
                              height: 1.4,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter an amount';
                            }
                            final parsed =
                                double.tryParse(v.replaceAll(',', '.'));
                            if (parsed == null || parsed <= 0) {
                              return 'Enter a valid amount';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ── Description ──
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(color: AppTheme.ink, fontSize: 15),
                  decoration: const InputDecoration(
                    labelText: 'What was it for?',
                    hintText: 'Dinner, groceries, gas\u2026',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ── Paid by ──
                DropdownButtonFormField<int>(
                  initialValue: _payerId,
                  style: const TextStyle(color: AppTheme.ink, fontSize: 15),
                  dropdownColor: AppTheme.surface,
                  iconEnabledColor: AppTheme.inkSecondary,
                  decoration: const InputDecoration(
                    labelText: 'Paid by',
                  ),
                  items: members
                      .map<DropdownMenuItem<int>>(
                        (Member m) => DropdownMenuItem<int>(
                          value: m.id,
                          child: Text(m.name),
                        ),
                      )
                      .toList(),
                  onChanged: members.isEmpty
                      ? null
                      : (v) => setState(() => _payerId = v),
                  validator: (v) => v == null ? 'Choose who paid' : null,
                ),
                const SizedBox(height: 14),

                // ── Date ──
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppTheme.border, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: AppTheme.inkSecondary,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Date',
                          style: TextStyle(
                            color: AppTheme.inkSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          dateFormat.format(_date),
                          style: const TextStyle(
                            color: AppTheme.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppTheme.inkMuted,
                        ),
                      ],
                    ),
                  ),
                ),

                if (_submitError != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.negative.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(
                        color: AppTheme.negative.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 18,
                          color: AppTheme.negative,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _submitError!,
                            style: const TextStyle(
                              color: AppTheme.negative,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 22),

                // ── Submit ──
                Opacity(
                  opacity: _submitting ? 0.6 : 1.0,
                  child: Material(
                    color: AppTheme.ink,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      onTap: _submitting ? null : _submit,
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        child: _submitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.background,
                                ),
                              )
                            : const Text(
                                'Add expense',
                                style: TextStyle(
                                  color: AppTheme.background,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _submitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.inkSecondary,
                    minimumSize: const Size.fromHeight(44),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
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