import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import '../l10n/l10n_ext.dart';

class TransactionEntryScreen extends StatefulWidget {
  final String type;
  final String category;

  const TransactionEntryScreen({
    super.key,
    required this.type,
    required this.category,
  });

  @override
  State<TransactionEntryScreen> createState() => _TransactionEntryScreenState();
}

class _TransactionEntryScreenState extends State<TransactionEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  Color get _blue => const Color.fromARGB(255, 26, 150, 233);
  Color get _purple => const Color.fromARGB(255, 71, 240, 130);
  Color get _red => const Color.fromARGB(255, 7, 143, 227);

  bool get _isIncome => widget.type == 'income';

  NumberFormat get _currencyFmt {
    final lc = Localizations.localeOf(context).languageCode;
    final name = lc == 'vi' ? 'vi_VN' : 'en_US';
    return NumberFormat.currency(locale: name, symbol: '₫', decimalDigits: 0);
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _formatCurrencyOnType(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      _amount.value = const TextEditingValue(text: '');
      return;
    }
    final number = double.parse(digits);
    final formatted = _currencyFmt.format(number).replaceAll('₫', '').trim();
    _amount.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
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

  void _save() {
    final t = context.l10n;
    if (!_formKey.currentState!.validate()) return;

    final raw = _amount.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(raw) ?? 0;
    final note = _note.text.trim();

    if (amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.amountMustBeGreaterThanZero)));
      return;
    }

    context.read<ExpenseModel>().addTransaction(
          type: widget.type,
          amount: amount,
          note: note,
          category: widget.category,
          date: _selectedDate,
        );

    final msg = _isIncome
        ? t.savedIncome(_currencyFmt.format(amount))
        : t.savedExpense(_currencyFmt.format(amount));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final accent = _isIncome ? Colors.green : Colors.redAccent;
    final icon = _isIncome ? Icons.south_west : Icons.north_east;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_blue, _purple, _red],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
              '${_isIncome ? t.incomeShort : t.expenseShort} - ${widget.category}'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_blue, _purple, _red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.92),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: accent.withOpacity(0.12),
                    child: Icon(icon, color: accent),
                  ),
                  title: Text(
                    _isIncome ? t.recordIncome : t.recordExpense,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text('${t.category}: ${widget.category}'),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.white.withOpacity(.96),
                shadowColor: Colors.black26,
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
                          controller: _amount,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]')),
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
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _note,
                          maxLines: 2,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: t.noteOptional,
                            prefixIcon: const Icon(Icons.note_alt_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
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
                                  '${_selectedDate.day.toString().padLeft(2, '0')}/'
                                  '${_selectedDate.month.toString().padLeft(2, '0')}/'
                                  '${_selectedDate.year}',
                                ),
                                const Icon(Icons.keyboard_arrow_down),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_blue, _purple, _red],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _save,
                              icon: const Icon(Icons.save_rounded),
                              label: Text(t.saveTransaction),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.92),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [50000, 100000, 200000, 500000, 1000000].map((v) {
                    final label =
                        _currencyFmt.format(v).replaceAll('₫', '').trim();
                    return ActionChip(
                      label: Text(label),
                      backgroundColor: Colors.white,
                      shape: StadiumBorder(
                        side: BorderSide(color: Colors.black12),
                      ),
                      onPressed: () {
                        _amount.text = label;
                        _amount.selection = TextSelection.collapsed(
                          offset: _amount.text.length,
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
