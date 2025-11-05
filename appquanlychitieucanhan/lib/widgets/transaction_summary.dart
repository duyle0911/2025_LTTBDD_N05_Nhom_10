import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';

class TransactionSummary extends StatelessWidget {
  final ExpenseModel expense;
  final String filter;
  final DateTimeRange? customRange;
  final String searchText;

  const TransactionSummary({
    super.key,
    required this.expense,
    required this.filter,
    this.customRange,
    required this.searchText,
  });

  NumberFormat _fmt(BuildContext context) {
    final lc = Localizations.localeOf(context).languageCode;
    final name = lc == 'vi' ? 'vi_VN' : 'en_US';
    return NumberFormat.currency(locale: name, symbol: '₫', decimalDigits: 0);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = _fmt(context);
    final now = DateTime.now();

    final data = expense.transactions.where((t) {
      final inFilter = switch (filter) {
        'all' => true,
        'today' => t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == now.day,
        'month' => t.date.year == now.year && t.date.month == now.month,
        'custom' when customRange != null => t.date.isAfter(
                customRange!.start.subtract(const Duration(days: 1))) &&
            t.date.isBefore(customRange!.end.add(const Duration(days: 1))),
        _ => true,
      };
      final q = searchText.toLowerCase();
      final inSearch = t.note.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q);
      return inFilter && inSearch;
    }).toList();

    double inc = 0, exp = 0;
    for (final t in data) {
      if (t.type == 'income')
        inc += t.amount;
      else
        exp += t.amount;
    }
    final bal = inc - exp;

    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
                child: _tile('Thu', fmt.format(inc),
                    Colors.green.withOpacity(.12), Colors.green)),
            const SizedBox(width: 8),
            Expanded(
                child: _tile('Chi', fmt.format(exp),
                    Colors.redAccent.withOpacity(.12), Colors.redAccent)),
            const SizedBox(width: 8),
            Expanded(
                child: _tile('Số dư', fmt.format(bal),
                    Colors.blue.withOpacity(.12), Colors.blue)),
          ],
        ),
      ),
    );
  }

  Widget _tile(String label, String value, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: fg)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: fg, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
