import 'package:flutter/foundation.dart';
import 'wallet_model.dart';

class TransactionItem {
  final String id;
  final String type;
  final double amount;
  final String note;
  final String category;
  final DateTime date;
  final String walletId;

  const TransactionItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.note,
    required this.category,
    required this.date,
    required this.walletId,
  });

  TransactionItem copyWith({
    String? id,
    String? type,
    double? amount,
    String? note,
    String? category,
    DateTime? date,
    String? walletId,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      category: category ?? this.category,
      date: date ?? this.date,
      walletId: walletId ?? this.walletId,
    );
  }
}

class ExpenseModel extends ChangeNotifier {
  final List<TransactionItem> _transactions = [];

  bool _isIncome(String t) => t.toLowerCase() == 'income';
  bool _isExpense(String t) => t.toLowerCase() == 'expense';

  double _clampAmount(double v) => (v.isNaN || v.isInfinite || v < 0) ? 0.0 : v;
  void _sortByDateDesc() =>
      _transactions.sort((a, b) => b.date.compareTo(a.date));

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

  String colorHexOf(String categoryName) =>
      _categoryColors[categoryName] ?? '#607D8B';
  void setCategoryColor(String category, String hex) {
    _categoryColors[category] = hex;
    notifyListeners();
  }

  double _signedAmountOf(TransactionItem t) =>
      _isIncome(t.type) ? t.amount : -t.amount;

  void _applyWalletDelta(WalletModel wm, String walletId, double delta) {
    final w = wm.byId(walletId);
    if (w == null) return;
    wm.adjustBalance(walletId, delta);
  }

  void addIncomeWithWallet(
    WalletModel wm,
    double amount,
    String note,
    String category, {
    DateTime? date,
    required String walletId,
  }) {
    final tx = TransactionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'income',
      amount: _clampAmount(amount),
      note: note.trim(),
      category: category,
      date: date ?? DateTime.now(),
      walletId: walletId,
    );
    _transactions.add(tx);
    _applyWalletDelta(wm, walletId, tx.amount);
    _sortByDateDesc();
    notifyListeners();
  }

  void addExpenseWithWallet(
    WalletModel wm,
    double amount,
    String note,
    String category, {
    DateTime? date,
    required String walletId,
  }) {
    final tx = TransactionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'expense',
      amount: _clampAmount(amount),
      note: note.trim(),
      category: category,
      date: date ?? DateTime.now(),
      walletId: walletId,
    );
    _transactions.add(tx);
    _applyWalletDelta(wm, walletId, -tx.amount);
    _sortByDateDesc();
    notifyListeners();
  }

  void addTransactionWithWallet({
    required WalletModel wm,
    required String type,
    required double amount,
    required String note,
    required String category,
    required String walletId,
    DateTime? date,
  }) {
    final amt = _clampAmount(amount);
    final n = note.trim();
    if (_isIncome(type)) {
      addIncomeWithWallet(wm, amt, n, category, date: date, walletId: walletId);
    } else {
      addExpenseWithWallet(wm, amt, n, category,
          date: date, walletId: walletId);
    }
  }

  void removeTransactionWithWallet(WalletModel wm, String id) {
    final idx = _transactions.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final removed = _transactions.removeAt(idx);
    _applyWalletDelta(wm, removed.walletId, -_signedAmountOf(removed));
    notifyListeners();
  }

  void removeTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void updateTransactionWithWallet(
    WalletModel wm,
    String id, {
    String? type,
    double? amount,
    String? note,
    String? category,
    DateTime? date,
    String? walletId,
  }) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final oldTx = _transactions[index];
    final newTx = oldTx.copyWith(
      type: type,
      amount: amount != null ? _clampAmount(amount) : null,
      note: note?.trim(),
      category: category,
      date: date,
      walletId: walletId,
    );

    final oldSigned = _signedAmountOf(oldTx);
    final newSigned = _signedAmountOf(newTx);

    if (oldTx.walletId == newTx.walletId) {
      final delta = newSigned - oldSigned;
      if (delta != 0) _applyWalletDelta(wm, newTx.walletId, delta);
    } else {
      _applyWalletDelta(wm, oldTx.walletId, -oldSigned);
      _applyWalletDelta(wm, newTx.walletId, newSigned);
    }

    _transactions[index] = newTx;
    _sortByDateDesc();
    notifyListeners();
  }

  void updateTransaction(
    String id, {
    String? type,
    double? amount,
    String? note,
    String? category,
    DateTime? date,
    String? walletId,
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
      walletId: walletId,
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
