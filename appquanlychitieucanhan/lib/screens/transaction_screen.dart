import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/expense_model.dart';
import 'transaction_entry_screen.dart';
import '../l10n/l10n_ext.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _section = 'income';
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  NumberFormat _currencyFmt(BuildContext context) {
    final lc = Localizations.localeOf(context).languageCode;
    final name = lc == 'vi' ? 'vi_VN' : 'en_US';
    return NumberFormat.currency(locale: name, symbol: '₫', decimalDigits: 0);
  }

  void _addCategory(ExpenseModel model, bool isIncome) {
    final t = context.l10n;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          isIncome ? t.addIncomeCategoryTitle : t.addExpenseCategoryTitle,
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: t.categoryNameHint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              final list =
                  isIncome ? model.incomeCategories : model.expenseCategories;
              if (list
                  .map((e) => e.toLowerCase())
                  .contains(name.toLowerCase())) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.categoryExists(name))),
                );
                return;
              }

              if (isIncome) {
                model.addIncomeCategory(name);
              } else {
                model.addExpenseCategory(name);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(t.categoryAdded(name))),
              );
              setState(() {});
            },
            child: Text(t.add),
          ),
        ],
      ),
    );
  }
//
  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final model = context.watch<ExpenseModel>();
    final isIncome = _section == 'income';
    final Color accent = isIncome ? Colors.green : Colors.redAccent;
    final IconData arrowIcon = isIncome ? Icons.south_west : Icons.north_east;

    final allCategories =
        isIncome ? model.incomeCategories : model.expenseCategories;
    final q = _search.text.trim().toLowerCase();
    final categories =
        allCategories.where((c) => c.toLowerCase().contains(q)).toList();

    final fmt = _currencyFmt(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.transactions),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 139, 215, 174),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 139, 215, 174),
        icon: const Icon(Icons.add),
        label: Text(t.addCategoryFAB),
        onPressed: () => _addCategory(model, isIncome),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'income',
                icon: const Icon(Icons.trending_up),
                label: Text(t.incomeFull),
              ),
              ButtonSegment(
                value: 'expense',
                icon: const Icon(Icons.trending_down),
                label: Text(t.expenseFull),
              ),
            ],
            selected: {_section},
            onSelectionChanged: (v) => setState(() {
              _section = v.first;
              _search.clear();
            }),
            showSelectedIcon: false,
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _search,
            decoration: InputDecoration(
              hintText: t.searchCategoryHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: q.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _search.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          if (categories.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  t.noCategoryMatch,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final cat = categories[i];
                final total = model.totalAmount(
                  type: isIncome ? 'income' : 'expense',
                  category: cat,
                );

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1.5,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: accent.withOpacity(0.12),
                      child: Icon(arrowIcon, color: accent),
                    ),
                    title: Text(
                      cat,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: total > 0
                        ? Text(
                            isIncome
                                ? '${t.alreadyIncome}: ${fmt.format(total)}'
                                : '${t.alreadyExpense}: ${fmt.format(total)}',
                            style: const TextStyle(color: Colors.grey),
                          )
                        : Text(
                            t.noTransactionsYet,
                            style: const TextStyle(color: Colors.grey),
                          ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransactionEntryScreen(
                            type: _section,
                            category: cat,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
