import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../l10n/l10n_ext.dart';

class StatisticsSummary extends StatelessWidget {
  final ExpenseModel expense;
  final String selectedChartType;
  final Function(String) onSelectType;
  final String filter;
  final DateTimeRange? customRange;
  final String searchText;

  const StatisticsSummary({
    super.key,
    required this.expense,
    required this.selectedChartType,
    required this.onSelectType,
    required this.filter,
    this.customRange,
    required this.searchText,
  });

  NumberFormat _moneyFmt(BuildContext context) {
    final lc = Localizations.localeOf(context).languageCode;
    final name = lc == 'vi' ? 'vi_VN' : 'en_US';
    return NumberFormat.currency(locale: name, symbol: '₫', decimalDigits: 0);
  }

  String _periodLabel(BuildContext context) {
    final t = context.l10n;
    final now = DateTime.now();
    final df = DateFormat('dd/MM/yyyy');
    return switch (filter) {
      'today' => '${t.today} • ${df.format(now)}',
      'month' => '${t.thisMonth} • ${DateFormat('MM/yyyy').format(now)}',
      'custom' when customRange != null =>
        '${t.range}: ${df.format(customRange!.start)} - ${df.format(customRange!.end)}',
      _ => t.allTime,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final fmtMoney = _moneyFmt(context);
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
    }).toList();

    double totalIncome = 0, totalExpense = 0;
    for (final tr in filtered) {
      if (tr.type == 'income') {
        totalIncome += tr.amount;
      } else {
        totalExpense += tr.amount;
      }
    }

    final net = totalIncome - totalExpense;
    final sum = totalIncome + totalExpense;
    final pIncome = sum == 0 ? 0.0 : totalIncome / sum;
    final pExpense = sum == 0 ? 0.0 : totalExpense / sum;
    final isIncomeSelected = selectedChartType == 'income';

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights, size: 18, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text(
                    t.summaryTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Text(_periodLabel(context),
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(
                        '${t.income}: ${fmtMoney.format(totalIncome)}  (${(pIncome * 100).toStringAsFixed(0)}%)'),
                    selected: isIncomeSelected,
                    onSelected: (_) => onSelectType('income'),
                    avatar: const Icon(Icons.trending_up,
                        size: 18, color: Colors.green),
                    selectedColor: Colors.green.withOpacity(0.12),
                    labelStyle: TextStyle(
                      color: isIncomeSelected
                          ? Colors.green.shade700
                          : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ChoiceChip(
                    label: Text(
                        '${t.expense}: ${fmtMoney.format(totalExpense)}  (${(pExpense * 100).toStringAsFixed(0)}%)'),
                    selected: !isIncomeSelected,
                    onSelected: (_) => onSelectType('expense'),
                    avatar: const Icon(Icons.trending_down,
                        size: 18, color: Colors.redAccent),
                    selectedColor: Colors.redAccent.withOpacity(0.12),
                    labelStyle: TextStyle(
                      color: !isIncomeSelected
                          ? Colors.redAccent.shade200
                          : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: pIncome.clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: Colors.redAccent.withOpacity(0.12),
                  valueColor: const AlwaysStoppedAnimation(Colors.green),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(t.moreIncome,
                      style: const TextStyle(color: Colors.green)),
                  Text(t.moreExpense,
                      style: const TextStyle(color: Colors.redAccent)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: (net >= 0 ? Colors.green : Colors.redAccent)
                      .withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      net >= 0
                          ? Icons.account_balance_wallet
                          : Icons.warning_amber_rounded,
                      color: net >= 0 ? Colors.green : Colors.redAccent,
                    ),
                    const SizedBox(width: 8),
                    Text('${t.netBalance}: ',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      fmtMoney.format(net),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: net >= 0 ? Colors.green : Colors.redAccent,
                      ),
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
