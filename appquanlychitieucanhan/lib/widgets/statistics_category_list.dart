import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../l10n/l10n_ext.dart';

class StatisticsCategoryList extends StatelessWidget {
  final ExpenseModel expense;
  final String selectedChartType;
  final String filter;
  final DateTimeRange? customRange;
  final String searchText;

  const StatisticsCategoryList({
    super.key,
    required this.expense,
    required this.selectedChartType,
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

    final filtered = expense.transactions.where((ttr) {
      bool matchFilter = switch (filter) {
        'all' => true,
        'today' => ttr.date.day == now.day &&
            ttr.date.month == now.month &&
            ttr.date.year == now.year,
        'month' => ttr.date.month == now.month && ttr.date.year == now.year,
        'custom' when customRange != null => ttr.date.isAfter(
                customRange!.start.subtract(const Duration(days: 1))) &&
            ttr.date.isBefore(customRange!.end.add(const Duration(days: 1))),
        _ => true,
      };
      final q = searchText.toLowerCase();
      final matchSearch = ttr.note.toLowerCase().contains(q) ||
          ttr.category.toLowerCase().contains(q);
      return matchFilter && matchSearch;
    }).toList();

    final Map<String, double> byCategory = {};
    final Map<String, int> countByCategory = {};
    double total = 0;

    for (final ttr in filtered) {
      final matchType =
          (selectedChartType == 'income' && ttr.type == 'income') ||
              (selectedChartType == 'expense' && ttr.type == 'expense');
      if (!matchType) continue;
      total += ttr.amount;
      byCategory[ttr.category] = (byCategory[ttr.category] ?? 0) + ttr.amount;
      countByCategory[ttr.category] = (countByCategory[ttr.category] ?? 0) + 1;
    }

    final items = byCategory.entries
        .map((e) => _CategoryRow(
              name: e.key,
              amount: e.value,
              percent: total == 0 ? 0.0 : e.value / total,
              count: countByCategory[e.key] ?? 0,
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            selectedChartType == 'income'
                ? t.noIncomeDataForFilter
                : t.noExpenseDataForFilter,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final barColor =
        selectedChartType == 'income' ? Colors.green : Colors.redAccent;
    final bg = barColor.withOpacity(0.12);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final it = items[i];
        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: bg,
                  child: Icon(
                    selectedChartType == 'income'
                        ? Icons.south_west
                        : Icons.north_east,
                    color: barColor,
                  ),
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
                              it.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(fmt.format(it.amount),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: it.percent.clamp(0.0, 1.0),
                                minHeight: 8,
                                backgroundColor: bg,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(barColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 56,
                            child: Text(
                              '${(it.percent * 100).toStringAsFixed(1)}%',
                              textAlign: TextAlign.right,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${t.transactionsCount}: ${it.count}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryRow {
  final String name;
  final double amount;
  final double percent;
  final int count;

  _CategoryRow({
    required this.name,
    required this.amount,
    required this.percent,
    required this.count,
  });
}
