import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../l10n/l10n_ext.dart';

class TransactionListView extends StatelessWidget {
  final ExpenseModel expense;
  final String filter;
  final DateTimeRange? customRange;
  final String searchText;

  const TransactionListView({
    super.key,
    required this.expense,
    required this.filter,
    this.customRange,
    required this.searchText,
  });

  NumberFormat _moneyFmt(BuildContext context) {
    final lc = Localizations.localeOf(context).languageCode;
    final name = lc == 'vi' ? 'vi_VN' : 'en_US';
    return NumberFormat.currency(locale: name, symbol: '₫', decimalDigits: 0);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final fmt = _moneyFmt(context);
    final now = DateTime.now();

    final filtered = expense.transactions.where((tr) {
      final matchFilter = switch (filter) {
        'today' => tr.date.day == now.day &&
            tr.date.month == now.month &&
            tr.date.year == now.year,
        'month' => tr.date.month == now.month && tr.date.year == now.year,
        'custom' when customRange != null => tr.date.isAfter(
                customRange!.start.subtract(const Duration(days: 1))) &&
            tr.date.isBefore(customRange!.end.add(const Duration(days: 1))),
        _ => true,
      };

      final q = searchText.toLowerCase();
      final matchSearch = tr.note.toLowerCase().contains(q) ||
          tr.category.toLowerCase().contains(q);
      return matchFilter && matchSearch;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long, size: 56, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                t.noTransactionsInRange,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    String keyOf(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final Map<String, List<TransactionItem>> byDay = {};
    for (final tr in filtered) {
      (byDay[keyOf(tr.date)] ??= []).add(tr);
    }

    final dayKeys = byDay.keys.toList()
      ..sort((a, b) {
        final da = DateTime.parse(a);
        final db = DateTime.parse(b);
        return db.compareTo(da);
      });

    String prettyDay(BuildContext context, DateTime d) {
      final now = DateTime.now();
      final isToday =
          d.year == now.year && d.month == now.month && d.day == now.day;
      final y = now.subtract(const Duration(days: 1));
      final isYesterday =
          d.year == y.year && d.month == y.month && d.day == y.day;
      if (isToday) return t.today;
      if (isYesterday) return t.yesterday;
      return DateFormat('dd/MM/yyyy').format(d);
    }

    Widget dayHeader(String k, List<TransactionItem> list) {
      double inc = 0, exp = 0;
      for (final tr in list) {
        if (tr.type == 'income') {
          inc += tr.amount;
        } else {
          exp += tr.amount;
        }
      }
      final date = DateTime.parse(k);
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
        child: Row(
          children: [
            Text(
              prettyDay(context, date),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            _miniPill('+ ${fmt.format(inc)}', Colors.green),
            const SizedBox(width: 8),
            _miniPill('- ${fmt.format(exp)}', Colors.redAccent),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: dayKeys.length,
      itemBuilder: (context, i) {
        final k = dayKeys[i];
        final list = byDay[k]!..sort((a, b) => b.date.compareTo(a.date));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            dayHeader(k, list),
            ...list
                .map((tr) => _TransactionTile(
                      item: tr,
                      fmt: fmt,
                      noNoteText: t.noNote,
                    ))
                .toList(),
            const SizedBox(height: 4),
          ],
        );
      },
    );
  }

  Widget _miniPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionItem item;
  final NumberFormat fmt;
  final String noNoteText;

  const _TransactionTile({
    required this.item,
    required this.fmt,
    required this.noNoteText,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = item.type == 'income';
    final icon = isIncome ? Icons.south_west : Icons.north_east;
    final color = isIncome ? Colors.green : Colors.redAccent;
    final time = DateFormat('HH:mm').format(item.date);
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(item.date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.note.isNotEmpty ? item.note : noNoteText,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            (isIncome ? '+ ' : '- ') + fmt.format(item.amount),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.category,
                                  size: 14, color: Colors.blueGrey),
                              const SizedBox(width: 4),
                              Text(item.category,
                                  style:
                                      const TextStyle(color: Colors.blueGrey)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.access_time,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(time,
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 12.5)),
                        const Spacer(),
                        Text(dateStr,
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
