import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdf;
import 'package:printing/printing.dart';
import '../models/expense_model.dart';
import '../widgets/statistics_chart.dart';
import '../widgets/statistics_summary.dart';
import '../widgets/statistics_category_list.dart';
import '../widgets/statistics_search.dart';
import '../widgets/statistics_cashflow.dart';
import '../l10n/l10n_ext.dart';
import '../theme/color_utils.dart';

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

  Color get _blue => const Color.fromARGB(255, 26, 150, 233);
  Color get _purple => const Color.fromARGB(255, 71, 240, 130);
  Color get _red => const Color.fromARGB(255, 7, 143, 227);

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

  Future<void> _exportPdf() async {
    final model = context.read<ExpenseModel>();
    final now = DateTime.now();
    final df = DateFormat('dd/MM/yyyy');
    final fmt =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    final filtered = model.transactions.where((tr) {
      final matchFilter = switch (_filter) {
        'all' => true,
        'today' => tr.date.day == now.day &&
            tr.date.month == now.month &&
            tr.date.year == now.year,
        'month' => tr.date.month == now.month && tr.date.year == now.year,
        'custom' when _customRange != null => tr.date.isAfter(
                _customRange!.start.subtract(const Duration(days: 1))) &&
            tr.date.isBefore(_customRange!.end.add(const Duration(days: 1))),
        _ => true,
      };
      final q = _searchText.toLowerCase();
      final matchSearch = tr.note.toLowerCase().contains(q) ||
          tr.category.toLowerCase().contains(q);
      return matchFilter && matchSearch;
    }).toList();

    double totalIncome = 0, totalExpense = 0;
    final incByCat = <String, double>{};
    final expByCat = <String, double>{};
    for (final tr in filtered) {
      if (tr.type == 'income') {
        totalIncome += tr.amount;
        incByCat[tr.category] = (incByCat[tr.category] ?? 0) + tr.amount;
      } else {
        totalExpense += tr.amount;
        expByCat[tr.category] = (expByCat[tr.category] ?? 0) + tr.amount;
      }
    }
    final incAgg = incByCat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final expAgg = expByCat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (ctx) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'BÁO CÁO THỐNG KÊ THU/CHI',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Row(children: [
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: const pdf.PdfColor.fromInt(0xFFE8F5E9),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Tổng thu',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(fmt.format(totalIncome)),
                    ]),
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: const pdf.PdfColor.fromInt(0xFFFFEBEE),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Tổng chi',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(fmt.format(totalExpense)),
                    ]),
              ),
            ),
          ]),
          pw.SizedBox(height: 14),
          pw.Text('Chi theo danh mục',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(width: .3),
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(),
              2: pw.FlexColumnWidth()
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                    color: pdf.PdfColor.fromInt(0xFFEEEEEE)),
                children: ['Danh mục', 'Số tiền', 'Tỉ lệ']
                    .map((h) => pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(h,
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ))
                    .toList(),
              ),
              ...expAgg.map<pw.TableRow>((e) {
                final c = pdfColorFromHex(model.colorHexOf(e.key));
                final pct = totalExpense == 0
                    ? '0%'
                    : '${(e.value * 100 / totalExpense).toStringAsFixed(1)}%';
                return pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Row(children: [
                      pw.Container(
                          width: 10,
                          height: 10,
                          decoration: pw.BoxDecoration(
                              color: c, shape: pw.BoxShape.circle)),
                      pw.SizedBox(width: 6),
                      pw.Text(e.key),
                    ]),
                  ),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(fmt.format(e.value))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(6), child: pw.Text(pct)),
                ]);
              }),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text('Thu theo danh mục',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(width: .3),
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(),
              2: pw.FlexColumnWidth()
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                    color: pdf.PdfColor.fromInt(0xFFEEEEEE)),
                children: ['Danh mục', 'Số tiền', 'Tỉ lệ']
                    .map((h) => pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(h,
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ))
                    .toList(),
              ),
              ...incAgg.map<pw.TableRow>((e) {
                final c = pdfColorFromHex(model.colorHexOf(e.key));
                final pct = totalIncome == 0
                    ? '0%'
                    : '${(e.value * 100 / totalIncome).toStringAsFixed(1)}%';
                return pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Row(children: [
                      pw.Container(
                          width: 10,
                          height: 10,
                          decoration: pw.BoxDecoration(
                              color: c, shape: pw.BoxShape.circle)),
                      pw.SizedBox(width: 6),
                      pw.Text(e.key),
                    ]),
                  ),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(fmt.format(e.value))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.all(6), child: pw.Text(pct)),
                ]);
              }),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text('Giao dịch gần đây',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Table.fromTextArray(
            headers: ['Ngày', 'Danh mục', 'Ghi chú', 'Số tiền'],
            data: filtered.take(50).map((t) {
              final sign = t.type == 'income' ? '+ ' : '- ';
              return [
                DateFormat('dd/MM').format(t.date),
                t.category,
                t.note,
                '$sign${fmt.format(t.amount)}'
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Khoảng thời gian: ${_filter == 'custom' && _customRange != null ? '${df.format(_customRange!.start)} - ${df.format(_customRange!.end)}' : _filter == 'month' ? DateFormat('MM/yyyy').format(now) : _filter == 'today' ? df.format(now) : 'Tất cả'}',
          ),
        ],
      ),
    );
    await Printing.sharePdf(
        bytes: await doc.save(), filename: 'Bao_cao_thu_chi.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final expense = context.watch<ExpenseModel>();
    final t = context.l10n;
    final df = DateFormat('dd/MM/yyyy');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_blue, _purple, _red],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(0, 94, 235, 193),
        appBar: AppBar(
          title: Text(t.tabStats),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(0, 179, 226, 77),
          elevation: 0,
          actions: [
            IconButton(
                tooltip: t.pickDateRange,
                onPressed: _pickCustomRange,
                icon: const Icon(Icons.date_range)),
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
            IconButton(
                tooltip: 'Xuất báo cáo',
                onPressed: _exportPdf,
                icon: const Icon(Icons.picture_as_pdf)),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.92),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    StatisticsSearch(
                      controller: _searchController,
                      searchText: _searchText,
                      onChanged: (val) =>
                          setState(() => _searchText = val.toLowerCase()),
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
                              onSelected: (_) => _selectFilter('all')),
                          ChoiceChip(
                              label: Text(t.filterToday),
                              selected: _filter == 'today',
                              onSelected: (_) => _selectFilter('today')),
                          ChoiceChip(
                              label: Text(t.filterThisMonth),
                              selected: _filter == 'month',
                              onSelected: (_) => _selectFilter('month')),
                          ChoiceChip(
                              label: Text(t.filterCustomEllipsis),
                              selected: _filter == 'custom',
                              onSelected: (_) => _pickCustomRange()),
                        ],
                      ),
                    ),
                    if (_filter == 'custom' && _customRange != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '${t.rangeLabel}: ${df.format(_customRange!.start)} - ${df.format(_customRange!.end)}',
                          style: const TextStyle(
                              color: Color.fromARGB(136, 127, 63, 230)),
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
                              label: Text(t.incomeShort)),
                          ButtonSegment(
                              value: 'expense',
                              icon: const Icon(Icons.trending_down),
                              label: Text(t.expenseShort)),
                        ],
                        selected: {_selectedChartType},
                        onSelectionChanged: (set) =>
                            setState(() => _selectedChartType = set.first),
                        showSelectedIcon: false,
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                        ),
                      ),
                    ),
                    StatisticsSummary(
                      expense: expense,
                      selectedChartType: _selectedChartType,
                      onSelectType: (type) =>
                          setState(() => _selectedChartType = type),
                      filter: _filter,
                      customRange: _customRange,
                      searchText: _searchText,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.92),
                    borderRadius: BorderRadius.circular(16)),
                child: StatisticsCashflow(
                  expense: expense,
                  filter: _filter,
                  customRange: _customRange,
                  searchText: _searchText,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.92),
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    StatisticsChart(
                      expense: expense,
                      selectedChartType: _selectedChartType,
                      filter: _filter,
                      customRange: _customRange,
                      searchText: _searchText,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: StatisticsCategoryList(
                        expense: expense,
                        selectedChartType: _selectedChartType,
                        filter: _filter,
                        customRange: _customRange,
                        searchText: _searchText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
