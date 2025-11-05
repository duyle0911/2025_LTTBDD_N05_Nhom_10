import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';

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

  // màu giống ảnh mẫu
  static const Color _incomeColor = Color(0xFF2E7D32); // xanh lá
  static const Color _expenseColor = Color(0xFFE53935); // đỏ

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // ---- Khoảng hiển thị theo filter ----
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
      // Tất cả -> lấy 30 ngày gần nhất cho biểu đồ
      end = DateTime(now.year, now.month, now.day);
      start = end.subtract(const Duration(days: 29));
    }

    final q = searchText.toLowerCase();

    // ---- Tổng theo ngày (KHÔNG cộng dồn) ----
    final incByDay = <DateTime, double>{};
    final expByDay = <DateTime, double>{};

    for (final t in expense.transactions) {
      // lọc theo khoảng + search
      if (t.date.isBefore(start) || t.date.isAfter(end)) continue;
      if (q.isNotEmpty &&
          !(t.note.toLowerCase().contains(q) ||
              t.category.toLowerCase().contains(q))) {
        continue;
      }
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      if (t.type == 'income') {
        incByDay[d] = (incByDay[d] ?? 0) + t.amount;
      } else {
        expByDay[d] = (expByDay[d] ?? 0) + t.amount;
      }
    }

    // luôn có đủ ngày liên tục để đường không bị đứt
    final days = <DateTime>[];
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      days.add(d);
      incByDay.putIfAbsent(d, () => 0);
      expByDay.putIfAbsent(d, () => 0);
    }
    if (days.isEmpty) return const SizedBox.shrink();

    final base = days.first;
    double xOf(DateTime d) => d.difference(base).inDays.toDouble();

    // spot theo GIÁ TRỊ NGÀY
    final spotsInc =
        days.map((d) => FlSpot(xOf(d), incByDay[d]!.toDouble())).toList();
    final spotsExp =
        days.map((d) => FlSpot(xOf(d), expByDay[d]!.toDouble())).toList();

    // trục Y động
    final maxY = [
      ...spotsInc.map((e) => e.y),
      ...spotsExp.map((e) => e.y),
    ].fold<double>(0, (p, n) => n > p ? n : p);

    final maxYShown = (maxY == 0 ? 1000.0 : maxY * 1.15);

    String dayLabel(double x) =>
        DateFormat('dd/MM').format(base.add(Duration(days: x.toInt())));
    String compact(num v) => NumberFormat.compact(locale: 'vi').format(v);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Biểu đồ thu/chi theo thời gian',
            style:
                TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
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
                    )),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: maxYShown / 4,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (v) =>
                      const FlLine(strokeWidth: .7, color: Colors.black12),
                  getDrawingVerticalLine: (v) =>
                      const FlLine(strokeWidth: .5, color: Colors.black12),
                ),
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
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    tooltipPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    tooltipBorder: const BorderSide(color: Colors.black26),
                    getTooltipItems: (spots) => spots.map((s) {
                      final d = base.add(Duration(days: s.x.toInt()));
                      final label = DateFormat('dd/MM').format(d);
                      final cur = NumberFormat.currency(
                              locale: 'vi_VN', symbol: '₫', decimalDigits: 0)
                          .format(s.y);
                      final which = s.barIndex == 0 ? 'Thu' : 'Chi';
                      return LineTooltipItem('$which\n$label\n$cur',
                          const TextStyle(fontSize: 11, color: Colors.white));
                    }).toList(),
                  ),
                ),
                lineBarsData: [
                  // Thu nhập (xanh lá)
                  LineChartBarData(
                    spots: spotsInc,
                    isCurved: true,
                    barWidth: 2,
                    color: _incomeColor,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                          radius: 2.8, color: _incomeColor, strokeWidth: 0),
                    ),
                  ),
                  // Chi tiêu (đỏ)
                  LineChartBarData(
                    spots: spotsExp,
                    isCurved: true,
                    barWidth: 2,
                    color: _expenseColor,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                          radius: 2.8, color: _expenseColor, strokeWidth: 0),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              _Legend(color: _incomeColor, text: 'Thu nhập'),
              SizedBox(width: 16),
              _Legend(color: _expenseColor, text: 'Chi tiêu'),
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
