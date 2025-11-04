import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../widgets/statistics_chart.dart';
import '../widgets/statistics_summary.dart';
import '../widgets/statistics_category_list.dart';
import '../widgets/statistics_search.dart';
import '../l10n/l10n_ext.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _filter = 'all';
  String _searchText = '';
  String _selectedChartType = 'expense';
  DateTimeRange? _customRange;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _customRange,
    );
    if (picked != null) {
      setState(() {
        _customRange = picked;
        _filter = 'custom';
      });
    }
  }

  void _selectFilter(String value) {
    setState(() {
      _filter = value;
      if (value != 'custom') _customRange = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final expense = context.watch<ExpenseModel>();
    final theme = Theme.of(context);
    final t = context.l10n; // ⬅️ non-null
    final df = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(t.tabStats),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 93, 174, 149),
        actions: [
          IconButton(
            tooltip: t.pickDateRange,
            onPressed: _pickCustomRange,
            icon: const Icon(Icons.date_range),
          ),
          PopupMenuButton<String>(
            tooltip: t.quickFilters,
            onSelected: _selectFilter,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'all', child: Text(t.filterAll)),
              PopupMenuItem(value: 'today', child: Text(t.filterToday)),
              PopupMenuItem(value: 'month', child: Text(t.filterThisMonth)),
              PopupMenuItem(value: 'custom', child: Text(t.filterCustom)),
            ],
            icon: const Icon(Icons.filter_alt),
          ),
        ],
      ),
      body: Column(
        children: [
          StatisticsSearch(
            controller: _searchController,
            searchText: _searchText,
            onChanged: (val) => setState(() => _searchText = val.toLowerCase()),
            onClear: () => setState(() => _searchText = ''),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(t.filterAll),
                  selected: _filter == 'all',
                  onSelected: (_) => _selectFilter('all'),
                ),
                ChoiceChip(
                  label: Text(t.filterToday),
                  selected: _filter == 'today',
                  onSelected: (_) => _selectFilter('today'),
                ),
                ChoiceChip(
                  label: Text(t.filterThisMonth),
                  selected: _filter == 'month',
                  onSelected: (_) => _selectFilter('month'),
                ),
                ChoiceChip(
                  label: Text(t.filterCustomEllipsis),
                  selected: _filter == 'custom',
                  onSelected: (_) => _pickCustomRange(),
                ),
              ],
            ),
          ),
          if (_filter == 'custom' && _customRange != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '${t.rangeLabel}: ${df.format(_customRange!.start)} - ${df.format(_customRange!.end)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'income',
                  icon: const Icon(Icons.trending_up),
                  label: Text(t.incomeShort),
                ),
                ButtonSegment(
                  value: 'expense',
                  icon: const Icon(Icons.trending_down),
                  label: Text(t.expenseShort),
                ),
              ],
              selected: {_selectedChartType},
              onSelectionChanged: (set) =>
                  setState(() => _selectedChartType = set.first),
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
          StatisticsSummary(
            expense: expense,
            selectedChartType: _selectedChartType,
            onSelectType: (type) => setState(() => _selectedChartType = type),
            filter: _filter,
            customRange: _customRange,
            searchText: _searchText,
          ),
          StatisticsChart(
            expense: expense,
            selectedChartType: _selectedChartType,
            filter: _filter,
            customRange: _customRange,
            searchText: _searchText,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: StatisticsCategoryList(
                expense: expense,
                selectedChartType: _selectedChartType,
                filter: _filter,
                customRange: _customRange,
                searchText: _searchText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
