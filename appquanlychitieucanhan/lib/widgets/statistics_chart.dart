import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense_model.dart';

class StatisticsChart extends StatelessWidget {
  final ExpenseModel expense;
  final String selectedChartType;
  final String filter;
  final DateTimeRange? customRange;
  final String searchText;

  const StatisticsChart({
    super.key,
    required this.expense,
    required this.selectedChartType,
    required this.filter,
    this.customRange,
    required this.searchText,
  });

  Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    bool inRange(DateTime d) {
      if (filter == 'custom' && customRange != null) {
        return !d.isBefore(customRange!.start) && !d.isAfter(customRange!.end);
      }
      if (filter == 'today') {
        final t = DateTime(now.year, now.month, now.day);
        final dd = DateTime(d.year, d.month, d.day);
        return t == dd;
      }
      if (filter == 'month') {
        return d.year == now.year && d.month == now.month;
      }
      return true;
    }

    final q = searchText.toLowerCase();
    final items = expense.transactions.where((t) {
      if (!inRange(t.date)) return false;
      if (selectedChartType == 'income' && t.type != 'income') return false;
      if (selectedChartType == 'expense' && t.type != 'expense') return false;
      if (q.isNotEmpty &&
          !(t.note.toLowerCase().contains(q) ||
              t.category.toLowerCase().contains(q))) {
        return false;
      }
      return true;
    }).toList();

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final byCat = <String, double>{};
    for (final t in items) {
      byCat[t.category] = (byCat[t.category] ?? 0) + t.amount;
    }
    final total = byCat.values.fold<double>(0, (s, v) => s + v);

    final sections = <PieChartSectionData>[];
    byCat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..forEach((e) {
        final percent = total == 0 ? 0.0 : (e.value / total * 100);
        final c = _hexToColor(expense.colorHexOf(e.key));
        sections.add(
          PieChartSectionData(
            color: c,
            value: e.value,
            title: '${percent.toStringAsFixed(1)}%',
            radius: 70,
            titleStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        );
      });

    return Padding(
      padding: const EdgeInsets.all(12),
      child: AspectRatio(
        aspectRatio: 1.2,
        child: PieChart(
          PieChartData(
            sections: sections,
            sectionsSpace: 2,
            centerSpaceRadius: 38,
            startDegreeOffset: -90,
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }
}
