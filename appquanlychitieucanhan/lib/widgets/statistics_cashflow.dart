import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../l10n/l10n_ext.dart';

class StatisticsCashflow extends StatelessWidget {
  final ExpenseModel expense;
  final String filter;
  final DateTimeRange? customRange;
  final String searchText;

  const StatisticsCashflow({
    super.key,
    required this.expense,
    required this.filter,
    this.customRange,
    required this.searchText,
  });

  static const Color _incomeColor = Color(0xFF2E7D32);
  static const Color _expenseColor = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final now = DateTime.now();

    DateTime start;
    DateTime end;
    if (filter == 'custom' && customRange != null) {
      start = DateTime(customRange!.start.year, customRange!.start.month,
          customRange!.start.day);
      end = DateTime(
          customRange!.end.year, customRange!.end.month, customRange!.end.day);
    } else if (filter == 'today') {
      start = DateTime(now.year, now.month, now.day);
      end = start;
    } else if (filter == 'month') {
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 1)
          .subtract(const Duration(days: 1));
    } else {
      end = DateTime(now.year, now.month, now.day);
      start = end.subtract(const Duration(days: 29));
    }

    final q = searchText.toLowerCase();
    final incByDay = <DateTime, double>{};
    final expByDay = <DateTime, double>{};

    for (final tItem in expense.transactions) {
      if (tItem.date.isBefore(start) || tItem.date.isAfter(end)) continue;
      if (q.isNotEmpty &&
          !(tItem.note.toLowerCase().contains(q) ||
              tItem.category.toLowerCase().contains(q))) continue;
      final d = DateTime(tItem.date.year, tItem.date.month, tItem.date.day);
      if (tItem.type == 'income') {
        incByDay[d] = (incByDay[d] ?? 0) + tItem.amount;
      } else {
        expByDay[d] = (expByDay[d] ?? 0) + tItem.amount;
      }
    }

    final days = <DateTime>[];
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      days.add(d);
      incByDay.putIfAbsent(d, () => 0);
      expByDay.putIfAbsent(d, () => 0);
    }
    if (days.isEmpty) return const SizedBox.shrink();

    final base = days.first;
    double xOf(DateTime d) => d.difference(base).inDays.toDouble();

    final spotsInc =
        days.map((d) => FlSpot(xOf(d), incByDay[d]!.toDouble())).toList();
    final spotsExp =
        days.map((d) => FlSpot(xOf(d), expByDay[d]!.toDouble())).toList();

    final maxY = [...spotsInc.map((e) => e.y), ...spotsExp.map((e) => e.y)]
        .fold<double>(0, (p, n) => n > p ? n : p);
    final maxYShown = (maxY == 0 ? 1000.0 : maxY * 1.15);

    String dayLabel(double x) =>
        DateFormat('dd/MM').format(base.add(Duration(days: x.toInt())));
    String compact(num v) =>
        NumberFormat.compact(locale: Localizations.localeOf(context).toString())
            .format(v);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.cashflowChartTitle,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 240,
            child: LineChart(
              LineChartData(
                minX: xOf(days.first),
                maxX: xOf(days.last),
                minY: 0,
                maxY: maxYShown,
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: Colors.black26, width: 0.7),
                    bottom: BorderSide(color: Colors.black26, width: 0.7),
                    right: BorderSide(color: Colors.transparent),
                    top: BorderSide(color: Colors.transparent),
                  ),
                ),
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (v, _) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(compact(v),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black87)),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (days.length <= 10)
                          ? 1
                          : (days.length / 6).ceilToDouble(),
                      getTitlesWidget: (v, _) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(dayLabel(v),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black87)),
                      ),
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(enabled: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spotsInc,
                    isCurved: true,
                    barWidth: 2,
                    color: _incomeColor,
                    dotData: FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: spotsExp,
                    isCurved: true,
                    barWidth: 2,
                    color: _expenseColor,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Legend(color: _incomeColor, text: t.incomeFull),
              const SizedBox(width: 16),
              _Legend(color: _expenseColor, text: t.expenseFull),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String text;
  const _Legend({super.key, required this.color, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.black87)),
      ],
    );
  }
}
