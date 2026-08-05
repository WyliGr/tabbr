import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/member.dart';
import '../providers/expense_provider.dart';

/// Design tokens (kept local so widgets render correctly regardless of theme).
class _T {
  static const bg = Color(0xFF0F1115);
  static const surface = Color(0xFF1A1D24);
  static const surfaceElevated = Color(0xFF22262E);
  static const primary = Color(0xFF7C5CFC);
  static const primaryBlue = Color(0xFF5B8DEF);
  static const negative = Color(0xFFFF6B6B);
  static const textPrimary = Color(0xFFF5F7FA);
  static const textMuted = Color(0xFF5C6378);
  static const divider = Color(0xFF2A2E38);
}

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
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _T.primary,
            onPrimary: Colors.white,
            surface: _T.surfaceElevated,
            onSurface: _T.textPrimary,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: _T.surfaceElevated),
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

  InputDecoration _inputDecoration({
    required String label,
    IconData? icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: _T.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      floatingLabelStyle: const TextStyle(
        color: _T.primary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      filled: true,
      fillColor: _T.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIcon: icon != null
          ? Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(icon, size: 20, color: _T.textMuted),
            )
          : null,
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _T.divider, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _T.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _T.negative, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _T.negative, width: 1.5),
      ),
    );
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
        decoration: const BoxDecoration(
          color: _T.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: _T.divider, width: 0.5),
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 20),
                    decoration: BoxDecoration(
                      color: _T.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Title
                const Text(
                  'Add expense',
                  style: TextStyle(
                    color: _T.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Large amount input
                const Text(
                  'AMOUNT',
                  style: TextStyle(
                    color: _T.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: _T.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _T.divider, width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Text(
                        '€',
                        style: TextStyle(
                          color: _T.textMuted,
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
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: _T.textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            height: 1.4,
                          ),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: const TextStyle(
                              color: _T.textMuted,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
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
                const SizedBox(height: 18),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(color: _T.textPrimary, fontSize: 15),
                  decoration: _inputDecoration(
                    label: 'Description',
                    icon: Icons.description_rounded,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Paid by — styled DropdownButtonFormField
                DropdownButtonFormField<int>(
                  initialValue: _payerId,
                  style: const TextStyle(color: _T.textPrimary, fontSize: 15),
                  dropdownColor: _T.surfaceElevated,
                  iconEnabledColor: _T.textMuted,
                  decoration: _inputDecoration(
                    label: 'Paid by',
                    icon: Icons.person_rounded,
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

                // Date — tappable card
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _T.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _T.divider, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            size: 20,
                            color: _T.textMuted,
                          ),
                        ),
                        const Text(
                          'DATE',
                          style: TextStyle(
                            color: _T.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            dateFormat.format(_date),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: _T.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: _T.textMuted,
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
                      color: _T.negative.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _T.negative.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 18,
                          color: _T.negative,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _submitError!,
                            style: const TextStyle(
                              color: _T.negative,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 22),

                // Submit button — gradient
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_T.primary, _T.primaryBlue],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _T.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _submitting ? null : _submit,
                      child: Center(
                        child: _submitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Add expense',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _submitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: _T.textMuted,
                    minimumSize: const Size.fromHeight(44),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 15,
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