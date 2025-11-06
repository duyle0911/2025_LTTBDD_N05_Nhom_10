import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import '../models/wallet_model.dart';
import '../l10n/l10n_ext.dart';
import '../screens/wallet_screen.dart';

class TransactionEntryScreen extends StatefulWidget {
  final String type;
  final String category;
  const TransactionEntryScreen(
      {super.key, required this.type, required this.category});

  @override
  State<TransactionEntryScreen> createState() => _TransactionEntryScreenState();
}

class _TransactionEntryScreenState extends State<TransactionEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedWalletId;

  bool get _isIncome => widget.type == 'income';

  NumberFormat get _currencyFmt {
    final lc = Localizations.localeOf(context).languageCode;
    final name = lc == 'vi' ? 'vi_VN' : 'en_US';
    return NumberFormat.currency(locale: name, symbol: '₫', decimalDigits: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wm = context.read<WalletModel>();
    _selectedWalletId ??= wm.selectedWalletId ??
        (wm.wallets.isNotEmpty ? wm.wallets.first.id : null);
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

    if (_selectedWalletId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.selectWalletHint)));
      return;
    }

    final raw = _amount.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(raw) ?? 0;
    final note = _note.text.trim();

    if (amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.amountMustBeGreaterThanZero)));
      return;
    }

    final wm = context.read<WalletModel>();
    context.read<ExpenseModel>().addTransactionWithWallet(
          wm: wm,
          type: widget.type,
          amount: amount,
          note: note,
          category: widget.category,
          walletId: _selectedWalletId!,
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${_isIncome ? t.incomeShort : t.expenseShort} - ${widget.category}'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: CircleAvatar(
                  backgroundColor: accent.withOpacity(0.12),
                  child: Icon(icon, color: accent)),
              title: Text(_isIncome ? t.recordIncome : t.recordExpense,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${t.category}: ${widget.category}'),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Consumer<WalletModel>(
                  builder: (_, wm, __) {
                    final hasWallet = wm.wallets.isNotEmpty;
                    _selectedWalletId ??= wm.selectedWalletId ??
                        (hasWallet ? wm.wallets.first.id : null);

                    if (!hasWallet) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Chọn ví thanh toán',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orangeAccent),
                            ),
                            child: const Text(
                                'Chưa có ví. Hãy tạo một ví để ghi giao dịch.'),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Tạo ví ngay'),
                              onPressed: () async {
                                await Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => const WalletScreen()));
                                if (!mounted) return;
                                final refreshed = context.read<WalletModel>();
                                if (refreshed.wallets.isNotEmpty) {
                                  setState(() {
                                    _selectedWalletId =
                                        refreshed.selectedWalletId ??
                                            refreshed.wallets.first.id;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedWalletId,
                                isExpanded: true,
                                items: [
                                  for (final w in wm.wallets)
                                    DropdownMenuItem(
                                        value: w.id,
                                        child:
                                            Text('${w.name} (${w.currency})')),
                                ],
                                onChanged: (v) =>
                                    setState(() => _selectedWalletId = v),
                                validator: (v) =>
                                    v == null ? t.selectWalletHint : null,
                                decoration: InputDecoration(
                                  labelText: t.wallet,
                                  prefixIcon: const Icon(Icons.wallet_outlined),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Quản lý ví',
                              onPressed: () async {
                                await Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => const WalletScreen()));
                                if (!mounted) return;
                                final refreshed = context.read<WalletModel>();
                                setState(() {
                                  _selectedWalletId =
                                      refreshed.selectedWalletId ??
                                          (refreshed.wallets.isNotEmpty
                                              ? refreshed.wallets.first.id
                                              : null);
                                });
                              },
                              icon: const Icon(Icons.manage_accounts),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_selectedWalletId != null)
                          Builder(builder: (_) {
                            final w = wm.byId(_selectedWalletId!);
                            final fmt = NumberFormat.currency(
                                locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  'Số dư: ${fmt.format(w?.balance ?? 0)}',
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(.6))),
                            );
                          }),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(children: [
                    TextFormField(
                      controller: _amount,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
                      ],
                      decoration: InputDecoration(
                        labelText: t.amount,
                        hintText: t.amountHint,
                        prefixIcon: const Icon(Icons.attach_money),
                        suffixText: t.vndSuffix,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) {
                        final raw = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
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
                            borderRadius: BorderRadius.circular(12)),
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
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}'),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.save_rounded),
                        label: Text(t.saveTransaction),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [50000, 100000, 200000, 500000, 1000000].map((v) {
                final label = _currencyFmt.format(v).replaceAll('₫', '').trim();
                return ActionChip(
                  label: Text(label),
                  onPressed: () {
                    _amount.text = label;
                    _amount.selection =
                        TextSelection.collapsed(offset: _amount.text.length);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
