import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/expense_model.dart';
import '../models/wallet_model.dart';
import '../l10n/l10n_ext.dart';
import 'wallet_screen.dart';

class TransactionEntryScreen extends StatefulWidget {
  final String type;
  final String category;
  final String? editTransactionId;

  const TransactionEntryScreen({
    super.key,
    required this.type,
    required this.category,
    this.editTransactionId,
  });

  @override
  State<TransactionEntryScreen> createState() => _TransactionEntryScreenState();
}

class _TransactionEntryScreenState extends State<TransactionEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedWalletId;
  String? _selectedCategory;

  bool get _isIncome => widget.type == 'income';
  bool get _isEditing => widget.editTransactionId != null;

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
    _selectedCategory ??= widget.category;

    if (_isEditing) {
      final m = context.read<ExpenseModel>();
      final tr = m.transactions.firstWhere(
        (t) => t.id == widget.editTransactionId,
        orElse: () => throw ArgumentError('transaction_not_found'),
      );
      _selectedWalletId = tr.walletId;
      _selectedCategory = tr.category;
      _selectedDate = tr.date;
      _note.text = tr.note;
      _amount.text = _currencyFmt.format(tr.amount).replaceAll('₫', '').trim();
    }
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

  Future<void> _showAddCategoryDialog() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thêm danh mục'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Tên danh mục'),
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Thêm')),
        ],
      ),
    );
    if (ok == true && ctrl.text.trim().isNotEmpty) {
      context.read<ExpenseModel>().addCategory(widget.type, ctrl.text.trim());
      setState(() => _selectedCategory = ctrl.text.trim());
    }
  }

  Future<void> _showManageCategoriesSheet() async {
    final m = context.read<ExpenseModel>();
    final list = m.categoriesOf(widget.type);

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final name = list[i];
            return ListTile(
              title: Text(name),
              trailing: PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'rename') {
                    final c = TextEditingController(text: name);
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Đổi tên danh mục'),
                        content: TextField(controller: c),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Hủy')),
                          FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Lưu')),
                        ],
                      ),
                    );
                    if (ok == true && c.text.trim().isNotEmpty) {
                      m.renameCategory(widget.type, name, c.text.trim());
                      if (_selectedCategory == name) {
                        setState(() => _selectedCategory = c.text.trim());
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    }
                  } else if (v == 'delete') {
                    if (name == 'Khác') return;
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Xóa danh mục'),
                        content: Text(
                            'Chuyển các giao dịch thuộc "$name" sang "Khác". Tiếp tục?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Hủy')),
                          FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Xóa')),
                        ],
                      ),
                    );
                    if (ok == true) {
                      m.removeCategory(widget.type, name, moveTo: 'Khác');
                      if (_selectedCategory == name)
                        setState(() => _selectedCategory = 'Khác');
                      if (ctx.mounted) Navigator.pop(ctx);
                    }
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'rename', child: Text('Đổi tên')),
                  PopupMenuItem(value: 'delete', child: Text('Xóa')),
                ],
              ),
              onTap: () {
                setState(() => _selectedCategory = name);
                Navigator.pop(ctx);
              },
            );
          },
        ),
      ),
    );
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
    if (amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.amountMustBeGreaterThanZero)));
      return;
    }

    final wm = context.read<WalletModel>();
    final m = context.read<ExpenseModel>();
    final cat = _selectedCategory ?? widget.category;

    if (_isEditing) {
      m.updateTransactionWithWallet(
        wm,
        widget.editTransactionId!,
        type: widget.type,
        amount: amount,
        note: _note.text.trim(),
        category: cat,
        date: _selectedDate,
        walletId: _selectedWalletId,
      );
    } else {
      m.addTransactionWithWallet(
        wm: wm,
        type: widget.type,
        amount: amount,
        note: _note.text.trim(),
        category: cat,
        walletId: _selectedWalletId!,
        date: _selectedDate,
      );
    }

    Navigator.pop(context);
  }

  void _deleteIfEditing() {
    final wm = context.read<WalletModel>();
    final m = context.read<ExpenseModel>();
    if (_isEditing) {
      m.removeTransactionWithWallet(wm, widget.editTransactionId!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final accent = _isIncome ? Colors.green : Colors.redAccent;
    final icon = _isIncome ? Icons.south_west : Icons.north_east;

    final m = context.watch<ExpenseModel>();
    final categories = m.categoriesOf(widget.type);

    return Scaffold(
      appBar: AppBar(
        title: Text('${_isIncome ? t.incomeShort : t.expenseShort}'),
        centerTitle: true,
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Xóa giao dịch',
              onPressed: _deleteIfEditing,
              icon: const Icon(Icons.delete_forever, color: Colors.red),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: accent.withOpacity(0.12),
                child: Icon(icon, color: accent),
              ),
              title: Text(_isIncome ? t.recordIncome : t.recordExpense,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle:
                  Text('Danh mục: ${_selectedCategory ?? widget.category}'),
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
                                  setState(() => _selectedWalletId =
                                      refreshed.selectedWalletId ??
                                          refreshed.wallets.first.id);
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    }

                    return DropdownButtonFormField<String>(
                      value: _selectedWalletId,
                      isExpanded: true,
                      items: [
                        for (final w in wm.wallets)
                          DropdownMenuItem(
                              value: w.id, child: Text('${w.name} (VND)')),
                      ],
                      onChanged: (v) => setState(() => _selectedWalletId = v),
                      decoration: InputDecoration(
                        labelText: t.wallet,
                        prefixIcon: const Icon(Icons.wallet_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null ? t.selectWalletHint : null,
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
                  child: Column(
                    children: [
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
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Danh mục',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in categories)
                          ChoiceChip(
                            label: Text(c),
                            selected:
                                (_selectedCategory ?? widget.category) == c,
                            onSelected: (_) =>
                                setState(() => _selectedCategory = c),
                          ),
                        ActionChip(
                          avatar: const Icon(Icons.add, size: 18),
                          label: const Text('Thêm danh mục'),
                          onPressed: _showAddCategoryDialog,
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.manage_accounts, size: 18),
                          label: const Text('Quản lý danh mục'),
                          onPressed: _showManageCategoriesSheet,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_rounded),
                label: Text(_isEditing ? 'Lưu thay đổi' : t.saveTransaction),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
