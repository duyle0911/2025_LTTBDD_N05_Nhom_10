import 'package:flutter/foundation.dart';

class WalletItem {
  final String id;
  final String name;
  final String type;
  final String currency;
  final String colorHex;
  double balance;

  WalletItem({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.currency = 'VND',
    this.colorHex = '#1976D2',
  });

  WalletItem copyWith({
    String? id,
    String? name,
    String? type,
    double? balance,
    String? currency,
    String? colorHex,
  }) {
    return WalletItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  factory WalletItem.fromJson(Map<String, dynamic> j) => WalletItem(
        id: j['id'] as String,
        name: j['name'] as String,
        type: j['type'] as String,
        balance: (j['balance'] as num).toDouble(),
        currency: 'VND',
        colorHex: (j['colorHex'] as String?) ?? '#1976D2',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'balance': balance,
        'currency': 'VND',
        'colorHex': colorHex,
      };
}

class WalletModel extends ChangeNotifier {
  final List<WalletItem> _wallets = [];
  String? _selectedWalletId;

  static const List<String> _palette = [
    '#90CAF9', 
    '#A5D6A7', 
    '#80CBC4',
    '#FFCC80', 
    '#FFF59D', 
    '#CE93D8', 
    '#F48FB1', 
    '#B0BEC5',
  ];

  List<WalletItem> get wallets => List.unmodifiable(_wallets);
  String? get selectedWalletId => _selectedWalletId;

  WalletItem? byId(String id) {
    try {
      return _wallets.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  void select(String? id) {
    _selectedWalletId = id;
    notifyListeners();
  }

  String addWallet({
    required String name,
    required String type,
    double initialBalance = 0.0,
    String? colorHex,
  }) {
    final id = _genId();
    final assignedColor =
        colorHex ?? _palette[_wallets.length % _palette.length];
    final vnType = _normalizeTypeVN(type);

    _wallets.add(WalletItem(
      id: id,
      name: name.trim(),
      type: vnType,
      balance: _sanitize(initialBalance),
      currency: 'VND',
      colorHex: assignedColor,
    ));
    _selectedWalletId ??= id;
    notifyListeners();
    return id;
  }

  void updateWallet(
    String id, {
    String? name,
    String? type,
    double? balance,
    String? colorHex,
  }) {
    final idx = _wallets.indexWhere((w) => w.id == id);
    if (idx == -1) return;
    _wallets[idx] = _wallets[idx].copyWith(
      name: name,
      type: type != null ? _normalizeTypeVN(type) : null,
      balance: balance != null ? _sanitize(balance) : null,
      currency: 'VND',
      colorHex: colorHex,
    );
    notifyListeners();
  }

  void setWalletColor(String id, String colorHex) {
    final idx = _wallets.indexWhere((w) => w.id == id);
    if (idx == -1) return;
    _wallets[idx] = _wallets[idx].copyWith(colorHex: colorHex);
    notifyListeners();
  }

  void removeWallet(String id) {
    final idx = _wallets.indexWhere((w) => w.id == id);
    if (idx == -1) return;
    _wallets.removeAt(idx);
    if (_selectedWalletId == id) {
      _selectedWalletId = _wallets.isNotEmpty ? _wallets.first.id : null;
    }
    notifyListeners();
  }

  void adjustBalance(String walletId, double delta) {
    final w = byId(walletId);
    if (w == null) return;
    w.balance = _sanitize(w.balance + delta);
    notifyListeners();
  }

  void seedIfEmpty() {
    if (_wallets.isNotEmpty) return;
    final firstId =
        addWallet(name: 'Tiền mặt', type: 'Tiền mặt', initialBalance: 0);
    addWallet(name: 'Ngân hàng', type: 'Ngân hàng', initialBalance: 0);
    _selectedWalletId = firstId;
    notifyListeners();
  }

  String _normalizeTypeVN(String t) {
    final s = t.trim().toLowerCase();
    if (s == 'cash' || s == 'tiền mặt') return 'Tiền mặt';
    if (s == 'bank' || s == 'ngân hàng') return 'Ngân hàng';
    if (s == 'credit' || s == 'thẻ tín dụng' || s == 'the tin dung')
      return 'Thẻ tín dụng';
    if (s == 'savings' || s == 'tiết kiệm' || s == 'tiet kiem')
      return 'Tiết kiệm';
    return t;
  }

  String _genId() => DateTime.now().microsecondsSinceEpoch.toString();

  double _sanitize(double v) {
    if (v.isNaN || v.isInfinite) return 0.0;
    return double.parse(v.toStringAsFixed(2));
  }
}
