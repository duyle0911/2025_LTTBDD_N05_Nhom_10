import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryIconStore {
  CategoryIconStore._();
  static final CategoryIconStore instance = CategoryIconStore._();

  static const _prefixIcon = 'cat_icon';
  static const _prefixColor = 'cat_color';

  Future<IconData> getIcon(String type, String name,
      {IconData? defaultIcon}) async {
    final sp = await SharedPreferences.getInstance();
    final iconName = sp.getString(_iconKey(type, name));
    if (iconName == null) {
      final suggest = suggestIcons(name).firstOrNull;
      if (suggest != null)
        return iconFromName(suggest) ?? (defaultIcon ?? Icons.category);
      return defaultIcon ?? Icons.category;
    }
    return iconFromName(iconName) ?? (defaultIcon ?? Icons.category);
  }

  Future<void> setIcon(String type, String name, String iconName) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_iconKey(type, name), iconName);
  }

  Future<Color?> getColor(String type, String name) async {
    final sp = await SharedPreferences.getInstance();
    final hex = sp.getString(_colorKey(type, name));
    if (hex == null) return null;
    return _colorFromHex(hex);
  }

  Future<void> setColor(String type, String name, Color color) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_colorKey(type, name), _hexFromColor(color));
  }

  Future<void> remove(String type, String name) async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_iconKey(type, name));
    await sp.remove(_colorKey(type, name));
  }

  Future<void> rename(String type, String oldName, String newName) async {
    final sp = await SharedPreferences.getInstance();
    final oldI = _iconKey(type, oldName);
    final oldC = _colorKey(type, oldName);
    final newI = _iconKey(type, newName);
    final newC = _colorKey(type, newName);
    final iconName = sp.getString(oldI);
    final colorHex = sp.getString(oldC);
    if (iconName != null) await sp.setString(newI, iconName);
    if (colorHex != null) await sp.setString(newC, colorHex);
    await sp.remove(oldI);
    await sp.remove(oldC);
  }

  String _iconKey(String type, String name) => '${_prefixIcon}_${type}_$name';
  String _colorKey(String type, String name) => '${_prefixColor}_${type}_$name';

  static const List<String> iconCandidates = [
    'restaurant',
    'coffee',
    'local_cafe',
    'fastfood',
    'lunch_dining',
    'shopping_cart',
    'store',
    'home',
    'receipt',
    'payments',
    'savings',
    'directions_bus',
    'directions_car',
    'taxi_alert',
    'flight',
    'local_taxi',
    'movie',
    'music_note',
    'stadium',
    'school',
    'work',
    'fitness_center',
    'medical_services',
    'healing',
    'favorite',
    'celebration',
    'wallet',
    'account_balance_wallet',
    'attach_money',
    'money',
    'trending_up',
    'trending_down',
    'stars',
    'card_giftcard',
    'cake',
    'pets',
    'child_friendly',
    'sports_esports',
    'local_gas_station',
    'phone_iphone',
    'devices',
    'lightbulb',
    'construction',
    'category'
  ];

  static final Map<String, IconData> nameToIcon = {
    'restaurant': Icons.restaurant,
    'coffee': Icons.coffee,
    'local_cafe': Icons.local_cafe,
    'fastfood': Icons.fastfood,
    'lunch_dining': Icons.lunch_dining,
    'shopping_cart': Icons.shopping_cart,
    'store': Icons.store,
    'home': Icons.home,
    'receipt': Icons.receipt,
    'payments': Icons.payments,
    'savings': Icons.savings,
    'directions_bus': Icons.directions_bus,
    'directions_car': Icons.directions_car,
    'taxi_alert': Icons.taxi_alert,
    'flight': Icons.flight,
    'local_taxi': Icons.local_taxi,
    'movie': Icons.movie,
    'music_note': Icons.music_note,
    'stadium': Icons.stadium,
    'school': Icons.school,
    'work': Icons.work,
    'fitness_center': Icons.fitness_center,
    'medical_services': Icons.medical_services,
    'healing': Icons.healing,
    'favorite': Icons.favorite,
    'celebration': Icons.celebration,
    'wallet': Icons.wallet,
    'account_balance_wallet': Icons.account_balance_wallet,
    'attach_money': Icons.attach_money,
    'money': Icons.money,
    'trending_up': Icons.trending_up,
    'trending_down': Icons.trending_down,
    'stars': Icons.stars,
    'card_giftcard': Icons.card_giftcard,
    'cake': Icons.cake,
    'pets': Icons.pets,
    'child_friendly': Icons.child_friendly,
    'sports_esports': Icons.sports_esports,
    'local_gas_station': Icons.local_gas_station,
    'phone_iphone': Icons.phone_iphone,
    'devices': Icons.devices,
    'lightbulb': Icons.lightbulb,
    'construction': Icons.construction,
    'category': Icons.category,
  };

  static IconData? iconFromName(String name) => nameToIcon[name];

  static String iconNameFromData(IconData data) {
    return nameToIcon.entries
        .firstWhere(
          (e) =>
              e.value.codePoint == data.codePoint &&
              e.value.fontFamily == data.fontFamily,
          orElse: () => const MapEntry('category', Icons.category),
        )
        .key;
  }

  static final Map<Pattern, List<String>> _keywordMap = {
    RegExp(r'(ăn|an|ăn uống|do an|đồ ăn|food|meal|restaurant)',
        caseSensitive: false): ['restaurant', 'fastfood', 'lunch_dining'],
    RegExp(r'(cafe|cà phê|coffee|local_cafe)', caseSensitive: false): [
      'coffee',
      'local_cafe'
    ],
    RegExp(r'(mua|shopping|shop|siêu thị|market|cart)', caseSensitive: false): [
      'shopping_cart',
      'store',
      'receipt'
    ],
    RegExp(r'(nhà|home|rent|tiền nhà)', caseSensitive: false): ['home'],
    RegExp(r'(xăng|xe|gas|fuel)', caseSensitive: false): [
      'local_gas_station',
      'directions_car',
      'taxi_alert'
    ],
    RegExp(r'(đi lại|bus|xe buýt|di chuyển)', caseSensitive: false): [
      'directions_bus',
      'directions_car',
      'local_taxi'
    ],
    RegExp(r'(điện thoại|phone|điện tử|devices)', caseSensitive: false): [
      'phone_iphone',
      'devices'
    ],
    RegExp(r'(sức khỏe|y tế|health|medical)', caseSensitive: false): [
      'medical_services',
      'healing',
      'fitness_center'
    ],
    RegExp(r'(giải trí|movie|nhạc|music|game)', caseSensitive: false): [
      'movie',
      'music_note',
      'sports_esports',
      'stadium'
    ],
    RegExp(r'(quà|gift|card|sinh nhật|birthday|cake)', caseSensitive: false): [
      'card_giftcard',
      'cake',
      'celebration',
      'stars'
    ],
    RegExp(r'(thú cưng|pet|pets)', caseSensitive: false): ['pets'],
    RegExp(r'(trẻ em|child)', caseSensitive: false): ['child_friendly'],
    RegExp(r'(học|school|education)', caseSensitive: false): [
      'school',
      'lightbulb'
    ],
    RegExp(r'(công việc|work|job)', caseSensitive: false): ['work'],
    RegExp(r'(tiết kiệm|saving|khoản tiết kiệm)', caseSensitive: false): [
      'savings'
    ],
    RegExp(r'(thu nhập|income|tiền vào)', caseSensitive: false): [
      'attach_money',
      'trending_up'
    ],
    RegExp(r'(chi tiêu|expense|tiền ra)', caseSensitive: false): [
      'money',
      'trending_down'
    ],
  };

  List<String> suggestIcons(String categoryName) {
    final s = (categoryName).toLowerCase();
    final List<String> out = [];
    for (final entry in _keywordMap.entries) {
      if ((entry.key is RegExp && (entry.key as RegExp).hasMatch(s)) ||
          (entry.key is String && s.contains(entry.key as String))) {
        out.addAll(entry.value);
      }
    }
    if (out.isEmpty) out.add('category');

    return out.toSet().toList();
  }

  Color defaultColorFor(String categoryName, {bool income = false}) {
    if (income) return const Color(0xFF2E7D32);
    final s = categoryName.toLowerCase();
    if (s.contains('ăn') ||
        s.contains('an') ||
        s.contains('cafe') ||
        s.contains('cà')) {
      return const Color(0xFFE91E63);
    }
    if (s.contains('xăng') || s.contains('xe') || s.contains('bus')) {
      return const Color(0xFFEF6C00);
    }
    if (s.contains('mua') || s.contains('shop') || s.contains('siêu')) {
      return const Color(0xFF3949AB);
    }
    if (s.contains('sức') || s.contains('y tế') || s.contains('health')) {
      return const Color(0xFF00897B);
    }
    return const Color(0xFFB71C1C);
  }

  static Color? _colorFromHex(String hex) {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) {
      return Color(int.parse('FF$h', radix: 16));
    } else if (h.length == 8) {
      return Color(int.parse(h, radix: 16));
    }
    return null;
  }

  static String _hexFromColor(Color c) {
    return '#${c.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
