import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/expense_model.dart';
import '../../models/wallet_model.dart';
import '../../models/category_icon_store.dart';
import '../../widgets/icon_picker.dart';
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

  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

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

  void _ensureSelectedCategory(ExpenseModel m) {
    _selectedCategory ??=
        (m.incomeCategories.isNotEmpty ? m.incomeCategories.first : 'Khác');
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

  void _submit() {
    final t = context.l10n;
    if (!_formKey.currentState!.validate()) return;

    final wm = context.read<WalletModel>();
    final wid = wm.selectedWalletId ??
        (wm.wallets.isNotEmpty ? wm.wallets.first.id : null);
    if (wid == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Vui lòng tạo/chọn ví')));
      return;
    }

    final raw = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(raw) ?? 0;
    final note = _noteController.text.trim();
    final category = _selectedCategory ?? 'Khác';

    if (amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.amountMustBeGreaterThanZero)));
      return;
    }

    context.read<ExpenseModel>().addIncomeWithWallet(
          wm,
          amount,
          note,
          category,
          walletId: wid,
          date: _selectedDate,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.savedIncome(_currencyFmt.format(amount)))),
    );
    Navigator.pop(context);
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

  Future<void> _openCategoryManager() async {
    final model = context.read<ExpenseModel>();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final nameCtrl = TextEditingController();
        String editingName = '';
        return StatefulBuilder(builder: (ctx, setSt) {
          final list = model.incomeCategories;
          return Padding(
            padding: EdgeInsets.fromLTRB(
                16, 12, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Quản lý danh mục thu',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                for (final c in list)
                  FutureBuilder<List<dynamic>>(
                    future: () async {
                      final icon =
                          await CategoryIconStore.instance.getIcon('income', c);
                      final color = await CategoryIconStore.instance
                              .getColor('income', c) ??
                          CategoryIconStore.instance
                              .defaultColorFor(c, income: true);
                      return [icon, color];
                    }(),
                    builder: (_, snap) {
                      final icon = (snap.data != null
                          ? snap.data![0] as IconData
                          : Icons.category);
                      final color = (snap.data != null
                          ? snap.data![1] as Color
                          : const Color(0xFF2E7D32));
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Icon(icon, color: color),
                          title: Text(c,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) async {
                              if (v == 'edit') {
                                final choice = await pickIconChoice(
                                  context,
                                  initialName:
                                      CategoryIconStore.iconNameFromData(icon),
                                  initialColor: color,
                                  suggested: CategoryIconStore.instance
                                      .suggestIcons(c),
                                );
                                if (choice != null) {
                                  await CategoryIconStore.instance
                                      .setIcon('income', c, choice.name);
                                  await CategoryIconStore.instance
                                      .setColor('income', c, choice.color);
                                  setSt(() {});
                                }
                              } else if (v == 'rename') {
                                nameCtrl.text = c;
                                await showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Đổi tên danh mục'),
                                    content: TextField(
                                      controller: nameCtrl,
                                      decoration: const InputDecoration(
                                          hintText: 'Tên mới'),
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Hủy')),
                                      FilledButton(
                                        onPressed: () async {
                                          final newName = nameCtrl.text.trim();
                                          if (newName.isNotEmpty &&
                                              newName != c) {
                                            await CategoryIconStore.instance
                                                .rename('income', c, newName);
                                            model.renameCategory(
                                                'income', c, newName);
                                            if (_selectedCategory == c)
                                              setState(() =>
                                                  _selectedCategory = newName);
                                          }

                                          Navigator.pop(context);
                                          setSt(() {});
                                        },
                                        child: const Text('Lưu'),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (v == 'delete') {
                                await CategoryIconStore.instance
                                    .remove('income', c);
                                model.removeCategory('income', c);
                                if (_selectedCategory == c)
                                  setState(() => _selectedCategory = 'Khác');
                                setSt(() {});
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Đổi biểu tượng & màu')),
                              PopupMenuItem(
                                  value: 'rename', child: Text('Đổi tên')),
                              PopupMenuItem(
                                  value: 'delete', child: Text('Xóa')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Thêm danh mục mới',
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm'),
                      onPressed: () async {
                        final n = nameCtrl.text.trim();
                        if (n.isEmpty) return;
                        model.addCategory('income', n);
                        final suggest =
                            CategoryIconStore.instance.suggestIcons(n);
                        await CategoryIconStore.instance
                            .setIcon('income', n, suggest.first);
                        await CategoryIconStore.instance.setColor(
                          'income',
                          n,
                          CategoryIconStore.instance
                              .defaultColorFor(n, income: true),
                        );
                        nameCtrl.clear();
                        setSt(() {});
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final model = context.watch<ExpenseModel>();
    _ensureSelectedCategory(model);

    final categories = model.incomeCategories;

    Future<Widget> _iconWithColor(String cat) async {
      final icon = await CategoryIconStore.instance.getIcon('income', cat);
      final color = await CategoryIconStore.instance.getColor('income', cat) ??
          CategoryIconStore.instance.defaultColorFor(cat, income: true);
      return Icon(icon, size: 20, color: color);
    }

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
                  borderRadius: BorderRadius.circular(16)),
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
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              items: categories.map((c) {
                                return DropdownMenuItem(
                                  value: c,
                                  child: FutureBuilder<Widget>(
                                    future: _iconWithColor(c),
                                    builder: (_, snap) => Row(
                                      children: [
                                        (snap.data ??
                                            const Icon(Icons.category,
                                                size: 20)),
                                        const SizedBox(width: 8),
                                        Text(c),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedCategory = v),
                              decoration: InputDecoration(
                                labelText: t.category,
                                prefixIcon: const Icon(Icons.category),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Quản lý danh mục',
                            onPressed: _openCategoryManager,
                            icon: const Icon(Icons.settings),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _noteController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: t.noteOptional,
                          prefixIcon: const Icon(Icons.note_alt_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
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
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  DateFormat('dd/MM/yyyy')
                                      .format(_selectedDate),
                                  style: theme.textTheme.bodyLarge),
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
                                borderRadius: BorderRadius.circular(12)),
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
              children: categories.take(8).map((c) {
                final selected = c == _selectedCategory;
                return FutureBuilder<Widget>(
                  future: () async {
                    final icon =
                        await CategoryIconStore.instance.getIcon('income', c);
                    final color = await CategoryIconStore.instance
                            .getColor('income', c) ??
                        CategoryIconStore.instance
                            .defaultColorFor(c, income: true);
                    return Icon(icon, size: 18, color: color);
                  }(),
                  builder: (_, snap) => ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        (snap.data ?? const Icon(Icons.category, size: 18)),
                        const SizedBox(width: 6),
                        Text(c),
                      ],
                    ),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCategory = c),
                    selectedColor: Colors.green.withOpacity(0.12),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
