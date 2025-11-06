// lib/models/expense_model.dart
import 'package:flutter/foundation.dart';
import 'wallet_model.dart';

class TransactionItem {
  final String id;
  final String type; // 'income' | 'expense'
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
    'Mua sắm',
    'Khác'
  ];

  List<String> get incomeCategories => List.unmodifiable(_incomeCategories);
  List<String> get expenseCategories => List.unmodifiable(_expenseCategories);
  List<String> categoriesOf(String type) =>
      _isIncome(type) ? incomeCategories : expenseCategories;

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

  void addCategory(String type, String name, {String? colorHex}) {
    final n = name.trim();
    if (n.isEmpty) return;
    final list = _isIncome(type) ? _incomeCategories : _expenseCategories;
    if (list.any((e) => e.toLowerCase() == n.toLowerCase())) return;

    final idxOther = list.indexOf('Khác');
    if (idxOther >= 0) {
      list.insert(idxOther, n);
    } else {
      list.add(n);
    }
    if (colorHex != null && colorHex.isNotEmpty) _categoryColors[n] = colorHex;
    notifyListeners();
  }

  void renameCategory(String type, String oldName, String newName) {
    final list = _isIncome(type) ? _incomeCategories : _expenseCategories;
    final idx = list.indexOf(oldName);
    final n = newName.trim();
    if (idx == -1 || n.isEmpty) return;
    if (list.any((e) => e.toLowerCase() == n.toLowerCase())) return;

    for (var i = 0; i < _transactions.length; i++) {
      final t = _transactions[i];
      final sameKind = (_isIncome(type) && _isIncome(t.type)) ||
          (_isExpense(type) && _isExpense(t.type));
      if (sameKind && t.category == oldName) {
        _transactions[i] = t.copyWith(category: n);
      }
    }
    _categoryColors[n] = _categoryColors[oldName] ?? '#607D8B';
    _categoryColors.remove(oldName);
    list[idx] = n;
    notifyListeners();
  }

  void removeCategory(String type, String name, {String moveTo = 'Khác'}) {
    final list = _isIncome(type) ? _incomeCategories : _expenseCategories;
    if (!list.contains(name) || name == 'Khác') return;

    final target = list.contains(moveTo) ? moveTo : 'Khác';
    for (var i = 0; i < _transactions.length; i++) {
      final t = _transactions[i];
      final sameKind = (_isIncome(type) && _isIncome(t.type)) ||
          (_isExpense(type) && _isExpense(t.type));
      if (sameKind && t.category == name) {
        _transactions[i] = t.copyWith(category: target);
      }
    }
    list.remove(name);
    _categoryColors.remove(name);
    notifyListeners();
  }

  double _signedAmountOf(TransactionItem t) =>
      _isIncome(t.type) ? t.amount : -t.amount;

  void _applyWalletDelta(WalletModel wm, String walletId, double delta) {
    if (wm.byId(walletId) == null) return;
    wm.adjustBalance(walletId, delta);
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
    final tx = TransactionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _isIncome(type) ? 'income' : 'expense',
      amount: _clampAmount(amount),
      note: note.trim(),
      category: category,
      date: date ?? DateTime.now(),
      walletId: walletId,
    );
    _transactions.add(tx);
    _applyWalletDelta(wm, walletId, _signedAmountOf(tx));
    _sortByDateDesc();
    notifyListeners();
  }

  void addIncomeWithWallet(
    WalletModel wm,
    double amount,
    String note,
    String category, {
    DateTime? date,
    required String walletId,
  }) {
    addTransactionWithWallet(
      wm: wm,
      type: 'income',
      amount: amount,
      note: note,
      category: category,
      walletId: walletId,
      date: date,
    );
  }

  void addExpenseWithWallet(
    WalletModel wm,
    double amount,
    String note,
    String category, {
    DateTime? date,
    required String walletId,
  }) {
    addTransactionWithWallet(
      wm: wm,
      type: 'expense',
      amount: amount,
      note: note,
      category: category,
      walletId: walletId,
      date: date,
    );
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

  void removeTransactionWithWallet(WalletModel wm, String id) {
    final idx = _transactions.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final removed = _transactions.removeAt(idx);
    _applyWalletDelta(wm, removed.walletId, -_signedAmountOf(removed));
    notifyListeners();
  }

  // Shims cho UI cũ
  void removeTransaction(String id, {WalletModel? wm}) {
    final idx = _transactions.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final removed = _transactions.removeAt(idx);
    if (wm != null)
      _applyWalletDelta(wm, removed.walletId, -_signedAmountOf(removed));
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
    WalletModel? wm,
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

    if (wm != null) {
      final oldSigned = _signedAmountOf(oldTx);
      final newSigned = _signedAmountOf(newTx);
      if (oldTx.walletId == newTx.walletId) {
        final delta = newSigned - oldSigned;
        if (delta != 0) _applyWalletDelta(wm, newTx.walletId, delta);
      } else {
        _applyWalletDelta(wm, oldTx.walletId, -oldSigned);
        _applyWalletDelta(wm, newTx.walletId, newSigned);
      }
    }

    _transactions[index] = newTx;
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
