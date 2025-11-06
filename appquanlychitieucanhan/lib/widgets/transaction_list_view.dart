import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/expense_model.dart';
import '../models/wallet_model.dart';

class TransactionListView extends StatelessWidget {
  final ExpenseModel expense;
  final String filter;
  final DateTimeRange? customRange;
  final String searchText;

  const TransactionListView({
    super.key,
    required this.expense,
    required this.filter,
    required this.customRange,
    required this.searchText,
  });

  NumberFormat _fmtVND(BuildContext context) {
    final lc = Localizations.localeOf(context).languageCode;
    final name = lc == 'vi' ? 'vi_VN' : 'en_US';
    return NumberFormat.currency(locale: name, symbol: '₫', decimalDigits: 0);
  }

  bool _matchFilter(TransactionItem t) {
    if (filter == 'all') return true;

    final now = DateTime.now();
    if (filter == 'today') {
      return t.date.year == now.year &&
          t.date.month == now.month &&
          t.date.day == now.day;
    }
    if (filter == 'month') {
      return t.date.year == now.year && t.date.month == now.month;
    }
    if (filter == 'custom' && customRange != null) {
      final start = DateTime(customRange!.start.year, customRange!.start.month,
          customRange!.start.day);
      final end = DateTime(customRange!.end.year, customRange!.end.month,
          customRange!.end.day, 23, 59, 59);
      return (t.date.isAtSameMomentAs(start) || t.date.isAfter(start)) &&
          (t.date.isAtSameMomentAs(end) || t.date.isBefore(end));
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final fmt = _fmtVND(context);
    final q = searchText.toLowerCase();

    final items = expense.transactions
        .where((t) => _matchFilter(t))
        .where((t) =>
            q.isEmpty ||
            t.note.toLowerCase().contains(q) ||
            t.category.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (items.isEmpty) {
      return const Center(child: Text('Không có giao dịch khớp bộ lọc'));
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      itemBuilder: (ctx, i) => _TransactionTile(item: items[i], fmt: fmt),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionItem item;
  final NumberFormat fmt;
  const _TransactionTile({required this.item, required this.fmt});

  Color get _accent => item.type == 'income' ? Colors.green : Colors.redAccent;
  IconData get _icon =>
      item.type == 'income' ? Icons.south_west : Icons.north_east;

  String _ddMMyyyy(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final wm = context.watch<WalletModel>();
    final wallet = wm.byId(item.walletId);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        leading: CircleAvatar(
          backgroundColor: _accent.withOpacity(.12),
          child: Icon(_icon, color: _accent),
        ),
        title: Text(item.note.isNotEmpty ? item.note : item.category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          '${item.category} • ${wallet?.name ?? '—'} • ${_ddMMyyyy(item.date)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              (item.type == 'income' ? '+ ' : '- ') + fmt.format(item.amount),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: _accent,
              ),
            ),
            const SizedBox(width: 6),
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'copy') {
                  final text = fmt.format(item.amount);
                  await Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã sao chép $text')));
                } else if (v == 'edit') {
                  await _openEditSheet(context, item);
                } else if (v == 'delete') {
                  await _confirmDelete(context, item);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                PopupMenuItem(value: 'delete', child: Text('Xóa')),
                PopupMenuItem(value: 'copy', child: Text('Sao chép số tiền')),
              ],
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, TransactionItem it) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa giao dịch'),
        content: const Text('Bạn có chắc muốn xóa giao dịch này?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_, false),
              child: const Text('Hủy')),
          FilledButton(
              onPressed: () => Navigator.pop(_, true),
              child: const Text('Xóa')),
        ],
      ),
    );
    if (ok == true) {
      final wm = context.read<WalletModel>();
      context.read<ExpenseModel>().removeTransactionWithWallet(wm, it.id);
    }
  }

  Future<void> _openEditSheet(BuildContext context, TransactionItem it) async {
    final expense = context.read<ExpenseModel>();
    final wm = context.read<WalletModel>();

    final amountCtrl =
        TextEditingController(text: it.amount.toStringAsFixed(0));
    final noteCtrl = TextEditingController(text: it.note);
    String type = it.type;
    String walletId = it.walletId;
    String category = it.category;
    DateTime date = it.date;

    final formKey = GlobalKey<FormState>();
    List<String> cats() =>
        type == 'income' ? expense.incomeCategories : expense.expenseCategories;

    NumberFormat fmt =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, bottom + 16),
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Chỉnh sửa giao dịch',
                  style: Theme.of(ctx)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'income', label: Text('Thu')),
                  ButtonSegment(value: 'expense', label: Text('Chi')),
                ],
                selected: {type},
                onSelectionChanged: (s) {
                  type = s.first;

                  if (!cats().contains(category)) {
                    category = cats().first;
                  }
                },
                showSelectedIcon: false,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: walletId,
                items: [
                  for (final w in wm.wallets)
                    DropdownMenuItem(value: w.id, child: Text(w.name))
                ],
                onChanged: (v) => walletId = v ?? walletId,
                decoration: InputDecoration(
                  labelText: 'Ví',
                  prefixIcon: const Icon(Icons.wallet_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: InputDecoration(
                  labelText: 'Số tiền',
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: 'đ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) {
                  final raw = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                  if (raw.isEmpty) return 'Nhập số tiền';
                  final d = double.tryParse(raw);
                  if (d == null || d <= 0) return 'Số tiền không hợp lệ';
                  return null;
                },
                onChanged: (v) {
                  final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                  if (digits.isEmpty) {
                    amountCtrl.value = const TextEditingValue(text: '');
                    return;
                  }
                  final number = double.parse(digits);
                  final formatted =
                      fmt.format(number).replaceAll('₫', '').trim();
                  amountCtrl.value = TextEditingValue(
                    text: formatted,
                    selection:
                        TextSelection.collapsed(offset: formatted.length),
                  );
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: category,
                items: cats()
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => category = v ?? category,
                decoration: InputDecoration(
                  labelText: 'Danh mục',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: noteCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Ghi chú (không bắt buộc)',
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDate: date,
                  );
                  if (picked != null) date = picked;
                },
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Ngày',
                    prefixIcon: const Icon(Icons.event),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_ddMMyyyy(date)),
                      const Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    final raw =
                        amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
                    final amt = double.tryParse(raw) ?? it.amount;
                    context.read<ExpenseModel>().updateTransactionWithWallet(
                          wm,
                          it.id,
                          type: type,
                          amount: amt,
                          note: noteCtrl.text.trim(),
                          category: category,
                          date: date,
                          walletId: walletId,
                        );
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Lưu thay đổi'),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}
