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
    final c = AppColors.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: c.accent,
                onPrimary: c.background,
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
    final c = AppColors.of(context);
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
                    margin: const EdgeInsets.only(top: 12, bottom: 16),
                    decoration: BoxDecoration(
                      color: c.borderStrong,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // ── Title ──
                Text(
                  'New expense',
                  style: TextStyle(
                    color: c.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Amount (hero input) ──
                Text(
                  'AMOUNT',
                  style: AppTheme.monoLabel(
                    fontSize: 9,
                    color: c.inkMuted,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: c.surfaceDim,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  child: Row(
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Text(
                        '\u20AC',
                        style: TextStyle(
                          color: c.inkMuted,
                          fontSize: 26,
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
                          style: AppTheme.mono(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: c.ink,
                            letterSpacing: -0.5,
                            height: 1.4,
                          ),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: AppTheme.mono(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: c.inkMuted,
                              letterSpacing: -0.5,
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
                const SizedBox(height: 14),

                // ── Description ──
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(color: c.ink, fontSize: 14),
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
                const SizedBox(height: 12),

                // ── Paid by ──
                DropdownButtonFormField<int>(
                  initialValue: _payerId,
                  style: TextStyle(color: c.ink, fontSize: 14),
                  dropdownColor: c.surface,
                  iconEnabledColor: c.inkSecondary,
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
                const SizedBox(height: 12),

                // ── Date ──
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: Container(
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: c.border, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: c.inkSecondary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Date',
                          style: TextStyle(
                            color: c.inkSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          dateFormat.format(_date),
                          style: AppTheme.mono(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: c.ink,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: c.inkMuted,
                        ),
                      ],
                    ),
                  ),
                ),

                if (_submitError != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: c.negative.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(
                        color: c.negative.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 16,
                          color: c.negative,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _submitError!,
                            style: TextStyle(
                              color: c.negative,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                // ── Submit ──
                Opacity(
                  opacity: _submitting ? 0.6 : 1.0,
                  child: Material(
                    color: c.ink,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      onTap: _submitting ? null : _submit,
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        child: _submitting
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: c.background,
                                ),
                              )
                            : Text(
                                'Add expense',
                                style: TextStyle(
                                  color: c.background,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: _submitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: c.inkSecondary,
                    minimumSize: const Size.fromHeight(40),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 13,
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