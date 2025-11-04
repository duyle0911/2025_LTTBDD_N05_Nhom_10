import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import 'transaction_entry_screen.dart';
import '../l10n/l10n_ext.dart';

class TransactionCategoryScreen extends StatefulWidget {
  final String type;
  const TransactionCategoryScreen({super.key, required this.type});

  @override
  State<TransactionCategoryScreen> createState() =>
      _TransactionCategoryScreenState();
}

class _TransactionCategoryScreenState extends State<TransactionCategoryScreen> {
  final _search = TextEditingController();

  bool get _isIncome => widget.type == 'income';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _addCategory(BuildContext context) {
    final t = context.l10n;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.addCategoryTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: t.addCategoryHint,
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
              final text = controller.text.trim();
              if (text.isEmpty) return;

              final model = context.read<ExpenseModel>();
              final current =
                  _isIncome ? model.incomeCategories : model.expenseCategories;

              final exists = current
                  .map((e) => e.toLowerCase())
                  .contains(text.toLowerCase());

              Navigator.pop(context);

              if (exists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.categoryExists(text))),
                );
                return;
              }

              if (_isIncome) {
                model.addIncomeCategory(text);
              } else {
                model.addExpenseCategory(text);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(t.categoryAdded(text))),
              );
              setState(() {});
            },
            child: Text(t.add),
          ),
        ],
      ),
    );
  }

  void _renameCategory(BuildContext context, String oldName) {
    final t = context.l10n;
    final controller = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.renameCategoryTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: t.renameCategoryHint,
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
              final newName = controller.text.trim();
              if (newName.isEmpty ||
                  newName.toLowerCase() == oldName.toLowerCase()) {
                Navigator.pop(context);
                return;
              }

              final model = context.read<ExpenseModel>();
              final current =
                  _isIncome ? model.incomeCategories : model.expenseCategories;

              final exists = current
                  .map((e) => e.toLowerCase())
                  .contains(newName.toLowerCase());

              Navigator.pop(context);

              if (exists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.categoryExists(newName))),
                );
                return;
              }

              if (_isIncome) {
                model.addIncomeCategory(newName);
              } else {
                model.addExpenseCategory(newName);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(t.categoryAdded(newName))),
              );
              setState(() {});
            },
            child: Text(t.save),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(BuildContext context, String name) async {
    final t = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.deleteCategoryTitle),
        content: Text(t.deleteCategoryConfirm(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.delete),
          ),
        ],
      ),
    );
    if (ok == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.deleteDemoNotice)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final model = context.watch<ExpenseModel>();
    final all = _isIncome ? model.incomeCategories : model.expenseCategories;
    final query = _search.text.trim().toLowerCase();
    final filtered = all.where((c) => c.toLowerCase().contains(query)).toList();

    final color = _isIncome ? Colors.green : Colors.redAccent;
    final icon = _isIncome ? Icons.arrow_downward : Icons.arrow_upward;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            _isIncome ? t.incomeCategoriesTitle : t.expenseCategoriesTitle),
        backgroundColor: color,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addCategory(context),
        backgroundColor: color,
        icon: const Icon(Icons.add),
        label: Text(t.addCategoryFAB),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: t.searchCategoryHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isNotEmpty
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
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text(t.noCategoryMatch))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final name = filtered[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1.5,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.12),
                            child: Icon(icon, color: color),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'rename') _renameCategory(context, name);
                              if (v == 'delete') _deleteCategory(context, name);
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                  value: 'rename', child: Text(t.renameDemo)),
                              PopupMenuItem(
                                  value: 'delete', child: Text(t.deleteDemo)),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TransactionEntryScreen(
                                  type: widget.type,
                                  category: name,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
