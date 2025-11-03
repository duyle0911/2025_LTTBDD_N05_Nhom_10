import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/expense_model.dart';
import '../../l10n/l10n_ext.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedCategoryKey = 'salary';
  DateTime _selectedDate = DateTime.now();

  static const _categoryKeys = [
    'salary',
    'bonus',
    'allowance',
    'investment',
    'other'
  ];

  NumberFormat get _currencyFmt {
    final locale = Localizations.localeOf(context);
    final name = (locale.languageCode == 'vi') ? 'vi_VN' : 'en_US';
    return NumberFormat.currency(locale: name, symbol: '₫', decimalDigits: 0);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _selectedDate,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _labelForCategory(BuildContext context, String key) {
    final t = context.l10n;
    switch (key) {
      case 'salary':
        return t.catSalary;
      case 'bonus':
        return t.catBonus;
      case 'allowance':
        return t.catAllowance;
      case 'investment':
        return t.catInvestment;
      default:
        return t.catOther;
    }
  }

  void _formatCurrencyOnType(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      _amountController.value = const TextEditingValue(text: '');
      return;
    }
    final number = double.parse(digits);
    final formatted = _currencyFmt.format(number).replaceAll('₫', '').trim();
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _submit() {
    final t = context.l10n;
    if (!_formKey.currentState!.validate()) return;

    final raw = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(raw) ?? 0;
    final note = _noteController.text.trim();

    if (amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.amountMustBeGreaterThanZero)));
      return;
    }

    final categoryLabel = _labelForCategory(context, _selectedCategoryKey);
    context.read<ExpenseModel>().addIncome(amount, note, categoryLabel);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.savedIncome(_currencyFmt.format(amount)))),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.addIncomeTitle),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        decoration: InputDecoration(
                          labelText: t.amount,
                          hintText: t.amountHint,
                          prefixIcon: const Icon(Icons.attach_money),
                          suffixText: t.vndSuffix,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) {
                          final raw =
                              (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                          if (raw.isEmpty) return t.pleaseEnterAmount;
                          final d = double.tryParse(raw);
                          if (d == null) return t.amountInvalid;
                          if (d <= 0) return t.amountMustBeGreaterThanZero;
                          return null;
                        },
                        onChanged: _formatCurrencyOnType,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCategoryKey,
                        items: _categoryKeys
                            .map((k) => DropdownMenuItem(
                                  value: k,
                                  child: Text(_labelForCategory(context, k)),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedCategoryKey = v!),
                        decoration: InputDecoration(
                          labelText: t.category,
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _noteController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: t.noteOptional,
                          prefixIcon: const Icon(Icons.note_alt_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: t.date,
                            prefixIcon: const Icon(Icons.event),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('dd/MM/yyyy').format(_selectedDate),
                                style: theme.textTheme.bodyLarge,
                              ),
                              const Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.save_rounded),
                          label: Text(t.saveIncome),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categoryKeys.map((k) {
                final selected = k == _selectedCategoryKey;
                return ChoiceChip(
                  label: Text(_labelForCategory(context, k)),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCategoryKey = k),
                  selectedColor: Colors.green.withOpacity(0.15),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
