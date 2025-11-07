import 'package:sqflite/sqflite.dart';
import 'app_db.dart';

class WalletDto {
  final String id;
  final String name;
  final String type;
  final String currency;
  final String colorHex;
  final double balance;
  final int createdAt;

  WalletDto({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.colorHex,
    required this.balance,
    required this.createdAt,
  });

  factory WalletDto.fromMap(Map<String, Object?> m) => WalletDto(
        id: m['id'] as String,
        name: m['name'] as String,
        type: m['type'] as String,
        currency: m['currency'] as String,
        colorHex: (m['color_hex'] as String?) ?? '#1976D2',
        balance: (m['balance'] as num).toDouble(),
        createdAt: (m['created_at'] as num).toInt(),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'currency': currency,
        'color_hex': colorHex,
        'balance': balance,
        'created_at': createdAt,
      };
}

class WalletDao {
  Future<Database> get _db async => AppDatabase().database;

  Future<List<WalletDto>> getAll() async {
    final db = await _db;
    final rows = await db.query('wallets', orderBy: 'created_at DESC');
    return rows.map(WalletDto.fromMap).toList();
  }

  Future<void> insert(WalletDto w) async {
    final db = await _db;
    await db.insert('wallets', w.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(WalletDto w) async {
    final db = await _db;
    await db.update('wallets', w.toMap(), where: 'id = ?', whereArgs: [w.id]);
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('wallets', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> changeBalance(String id, double delta) async {
    final db = await _db;
    await db.rawUpdate(
        'UPDATE wallets SET balance = balance + ? WHERE id = ?', [delta, id]);
  }
}
