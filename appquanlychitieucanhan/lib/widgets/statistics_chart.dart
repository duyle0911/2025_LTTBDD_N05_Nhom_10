import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../l10n/l10n_ext.dart';

class StatisticsChart extends StatefulWidget {
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

  @override
  State<StatisticsChart> createState() => _StatisticsChartState();
}

class _StatisticsChartState extends State<StatisticsChart> {
  int _touchedIndex = -1;

  Color _stableColorFor(String key, {bool income = true}) {
    final base = income ? _incomePalette : _expensePalette;
    final idx = key.hashCode.abs() % base.length;
    return base[idx];
  }

  NumberFormat _moneyFmt(BuildContext context) {
    final lc = Localizations.localeOf(context).languageCode;
    final name = lc == 'vi' ? 'vi_VN' : 'en_US';
    return NumberFormat.currency(locale: name, symbol: '₫', decimalDigits: 0);
  }

  static const _incomePalette = <Color>[
    Color.fromARGB(255, 27, 90, 249),
    Color.fromARGB(255, 26, 100, 237),
    Color.fromARGB(255, 35, 103, 239),
    Color.fromARGB(255, 11, 93, 217),
    Color.fromARGB(255, 57, 110, 223),
    Color.fromARGB(255, 43, 94, 236),
  ];

  static const _expensePalette = <Color>[
    Color.fromARGB(255, 225, 13, 77),
    Color(0xFFc0392b),
    Color.fromARGB(255, 229, 54, 127),
    Color.fromARGB(255, 242, 57, 94),
    Color.fromARGB(255, 197, 8, 84),
    Color.fromARGB(255, 243, 32, 95),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.l10n; // ⬅️
    final fmtMoney = _moneyFmt(context);
    final now = DateTime.now();

    final filtered = widget.expense.transactions.where((tr) {
      bool matchFilter = switch (widget.filter) {
        'all' => true,
        'today' => tr.date.day == now.day &&
            tr.date.month == now.month &&
            tr.date.year == now.year,
        'month' => tr.date.month == now.month && tr.date.year == now.year,
        'custom' when widget.customRange != null => tr.date.isAfter(
                widget.customRange!.start.subtract(const Duration(days: 1))) &&
            tr.date
                .isBefore(widget.customRange!.end.add(const Duration(days: 1))),
        _ => true,
      };
      final q = widget.searchText.toLowerCase();
      final matchSearch = tr.note.toLowerCase().contains(q) ||
          tr.category.toLowerCase().contains(q);
      return matchFilter && matchSearch;
    }).toList();

    final byCategory = <String, double>{};
    double total = 0;
    final isIncome = widget.selectedChartType == 'income';

    for (final tr in filtered) {
      if ((isIncome && tr.type == 'income') ||
          (!isIncome && tr.type == 'expense')) {
        total += tr.amount;
        byCategory[tr.category] = (byCategory[tr.category] ?? 0) + tr.amount;
      }
    }

    if (byCategory.isEmpty || total == 0) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          isIncome ? t.noIncomeDataForFilter : t.noExpenseDataForFilter,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sections = <PieChartSectionData>[];
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      final percent = e.value / total;
      final selected = i == _touchedIndex;
      final color = _stableColorFor(e.key, income: isIncome);
      sections.add(
        PieChartSectionData(
          color: color,
          value: e.value,
          radius: selected ? 88 : 78,
          showTitle: true,
          title: '${(percent * 100).toStringAsFixed(1)}%',
          titleStyle: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          badgeWidget: selected
              ? _Badge(
                  label: e.key, value: fmtMoney.format(e.value), color: color)
              : null,
          badgePositionPercentageOffset: .98,
        ),
      );
    }

    final accent = isIncome ? Colors.green : Colors.redAccent;

    return Column(
      children: [
        SizedBox(
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 54,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        setState(() => _touchedIndex = -1);
                        return;
                      }
                      setState(() => _touchedIndex =
                          response.touchedSection!.touchedSectionIndex);
                    },
                  ),
                ),
                swapAnimationDuration: const Duration(milliseconds: 500),
                swapAnimationCurve: Curves.easeOutCubic,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isIncome ? t.totalIncomeLabel : t.totalExpenseLabel,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fmtMoney.format(total),
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: accent,
                        fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: entries.map((e) {
              final color = _stableColorFor(e.key, income: isIncome);
              final percent = e.value / total * 100;
              return _LegendItem(
                color: color,
                title: e.key,
                valueText: fmtMoney.format(e.value),
                percentText: '${percent.toStringAsFixed(1)}%',
                selected:
                    _touchedIndex >= 0 && entries[_touchedIndex].key == e.key,
                onTap: () {
                  final idx = entries.indexWhere((x) => x.key == e.key);
                  setState(
                      () => _touchedIndex = _touchedIndex == idx ? -1 : idx);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String title;
  final String valueText;
  final String percentText;
  final bool selected;
  final VoidCallback onTap;

  const _LegendItem({
    required this.color,
    required this.title,
    required this.valueText,
    required this.percentText,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = selected ? Border.all(color: color, width: 1.2) : null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: border,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
            const SizedBox(width: 8),
            Text('• $valueText'),
            const SizedBox(width: 6),
            Text('($percentText)',
                style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Badge({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text(value, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
