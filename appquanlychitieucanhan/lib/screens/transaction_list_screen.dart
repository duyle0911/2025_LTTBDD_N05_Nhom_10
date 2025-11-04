import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../widgets/transaction_search.dart';
import '../widgets/transaction_summary.dart';
import '../widgets/transaction_list_view.dart';
import '../l10n/l10n_ext.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String _filter = 'all';
  String _searchText = '';
  final _searchController = TextEditingController();
  DateTimeRange? _customRange;

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
    final t = context.l10n; ️
    final df = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(t.transactionsTitle),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            tooltip: t.pickDateRange,
            onPressed: _pickCustomRange,
            icon: const Icon(Icons.date_range),
          ),
          PopupMenuButton<String>(
            tooltip: t.quickFilters,
            onSelected: _selectFilter,
            icon: const Icon(Icons.filter_alt),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'all', child: Text(t.filterAll)),
              PopupMenuItem(value: 'today', child: Text(t.filterToday)),
              PopupMenuItem(value: 'month', child: Text(t.filterThisMonth)),
              PopupMenuItem(value: 'custom', child: Text(t.filterCustom)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          TransactionSearch(
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
                '${t.rangeLabel}: ${df.format(_customRange!.start)}  -  ${df.format(_customRange!.end)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          TransactionSummary(
            expense: expense,
            filter: _filter,
            customRange: _customRange,
            searchText: _searchText,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 😎,
              child: TransactionListView(
                expense: expense,
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
