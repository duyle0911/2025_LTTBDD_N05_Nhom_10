import 'package:flutter/foundation.dart';

class TransactionItem {
  final String id;
  final String type;
  final double amount;
  final String note;
  final String category;
  final DateTime date;

  const TransactionItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.note,
    required this.category,
    required this.date,
  });

  TransactionItem copyWith({
    String? id,
    String? type,
    double? amount,
    String? note,
    String? category,
    DateTime? date,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }
}

class ExpenseModel extends ChangeNotifier {
  final List<TransactionItem> _transactions = [];

  bool _isIncome(String t) => t.toLowerCase() == 'income';
  bool _isExpense(String t) => t.toLowerCase() == 'expense';

  double _clampAmount(double v) => (v.isNaN || v.isInfinite || v < 0) ? 0.0 : v;

  void _sortByDateDesc() {
    _transactions.sort((a, b) => b.date.compareTo(a.date));
  }

  double get income => _transactions
      .where((t) => _isIncome(t.type))
      .fold(0, (s, t) => s + t.amount);

  double get expense => _transactions
      .where((t) => _isExpense(t.type))
      .fold(0, (s, t) => s + t.amount);

  double get balance => income - expense;

  List<TransactionItem> get transactions => List.unmodifiable(_transactions);

  final List<String> _incomeCategories = ['Lương', 'Thưởng', 'Khác'];
  final List<String> _expenseCategories = [
    'Ăn uống',
    'Đi lại',
    'Hóa đơn',
    'Mua sắm'
  ];

  List<String> get incomeCategories => List.unmodifiable(_incomeCategories);
  List<String> get expenseCategories => List.unmodifiable(_expenseCategories);

  final Map<String, String> _categoryColors = {
    'Ăn uống': '#E91E63',
    'Đi lại': '#9C27B0',
    'Hóa đơn': '#7C4DFF',
    'Mua sắm': '#3F51B5',
    'Lương': '#2E7D32',
    'Thưởng': '#00BCD4',
    'Khác': '#607D8B',
  };

  String colorHexOf(String categoryName) {
    return _categoryColors[categoryName] ?? '#607D8B';
  }

  void setCategoryColor(String category, String hex) {
    _categoryColors[category] = hex;
    notifyListeners();
  }

  void addIncomeCategory(String name) {
    if (!_incomeCategories.contains(name)) {
      _incomeCategories.add(name);
      notifyListeners();
    }
  }

  void addExpenseCategory(String name) {
    if (!_expenseCategories.contains(name)) {
      _expenseCategories.add(name);
      notifyListeners();
    }
  }

  void addIncome(double amount, String note, String category,
      {DateTime? date}) {
    _transactions.add(TransactionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'income',
      amount: _clampAmount(amount),
      note: note.trim(),
      category: category,
      date: date ?? DateTime.now(),
    ));
    _sortByDateDesc();
    notifyListeners();
  }

  void addExpense(double amount, String note, String category,
      {DateTime? date}) {
    _transactions.add(TransactionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'expense',
      amount: _clampAmount(amount),
      note: note.trim(),
      category: category,
      date: date ?? DateTime.now(),
    ));
    _sortByDateDesc();
    notifyListeners();
  }

  void addTransaction({
    required String type,
    required double amount,
    required String note,
    required String category,
    DateTime? date,
  }) {
    final amt = _clampAmount(amount);
    final n = note.trim();
    if (_isIncome(type)) {
      addIncome(amt, n, category, date: date);
    } else {
      addExpense(amt, n, category, date: date);
    }
  }

  void removeTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void updateTransaction(
    String id, {
    String? type,
    double? amount,
    String? note,
    String? category,
    DateTime? date,
  }) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final current = _transactions[index];
    _transactions[index] = current.copyWith(
      type: type,
      amount: amount != null ? _clampAmount(amount) : null,
      note: note?.trim(),
      category: category,
      date: date,
    );
    _sortByDateDesc();
    notifyListeners();
  }

  double totalAmount({required String type, String? category}) {
    return _transactions.where((t) {
      final matchType =
          _isIncome(type) ? _isIncome(t.type) : _isExpense(t.type);
      final matchCategory = category == null || t.category == category;
      return matchType && matchCategory;
    }).fold(0, (sum, t) => sum + t.amount);
  }

  Map<DateTime, double> sumByDay(String type) {
    final out = <DateTime, double>{};
    final isInc = _isIncome(type);
    for (final t in _transactions
        .where((t) => isInc ? _isIncome(t.type) : _isExpense(t.type))) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      out[d] = (out[d] ?? 0) + t.amount;
    }
    return out;
  }
}
