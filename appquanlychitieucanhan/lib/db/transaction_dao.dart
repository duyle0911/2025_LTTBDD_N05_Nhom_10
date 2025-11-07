import 'package:sqflite/sqflite.dart';
import 'app_db.dart';

class TransactionDto {
  final String id;
  final String walletId;
  final String categoryId;
  final double amount;
  final String? note;
  final int happenedAt;
  final bool isIncome;
  final int createdAt;

  TransactionDto({
    required this.id,
    required this.walletId,
    required this.categoryId,
    required this.amount,
    required this.happenedAt,
    required this.isIncome,
    required this.createdAt,
    this.note,
  });

  factory TransactionDto.fromMap(Map<String, Object?> m) => TransactionDto(
        id: m['id'] as String,
        walletId: m['wallet_id'] as String,
        categoryId: m['category_id'] as String,
        amount: (m['amount'] as num).toDouble(),
        note: m['note'] as String?,
        happenedAt: (m['happened_at'] as num).toInt(),
        isIncome: (m['is_income'] as num).toInt() == 1,
        createdAt: (m['created_at'] as num).toInt(),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'wallet_id': walletId,
        'category_id': categoryId,
        'amount': amount,
        'note': note,
        'happened_at': happenedAt,
        'is_income': isIncome ? 1 : 0,
        'created_at': createdAt,
      };
}

class TransactionDao {
  Future<Database> get _db async => AppDatabase().database;

  Future<void> insertAndAffectBalance(TransactionDto t) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.insert('transactions', t.toMap());
      final delta = t.isIncome ? t.amount : -t.amount;
      await txn.rawUpdate(
          'UPDATE wallets SET balance = balance + ? WHERE id = ?',
          [delta, t.walletId]);
    });
  }

  Future<void> deleteAndRevertBalance(String id) async {
    final db = await _db;
    await db.transaction((txn) async {
      final rows = await txn.query('transactions',
          where: 'id = ?', whereArgs: [id], limit: 1);
      if (rows.isEmpty) return;
      final t = TransactionDto.fromMap(rows.first);
      await txn.delete('transactions', where: 'id = ?', whereArgs: [id]);
      final delta = t.isIncome ? -t.amount : t.amount;
      await txn.rawUpdate(
          'UPDATE wallets SET balance = balance + ? WHERE id = ?',
          [delta, t.walletId]);
    });
  }

  Future<List<TransactionDto>> recent(
      {String? walletId, int limit = 50}) async {
    final db = await _db;
    final rows = await db.query(
      'transactions',
      where: walletId == null ? null : 'wallet_id = ?',
      whereArgs: walletId == null ? null : [walletId],
      orderBy: 'happened_at DESC',
      limit: limit,
    );
    return rows.map(TransactionDto.fromMap).toList();
  }

  Future<double> sumIncome({String? walletId}) async {
    final db = await _db;
    final r = await db.rawQuery(
      'SELECT IFNULL(SUM(amount),0) s FROM transactions WHERE is_income = 1 ${walletId == null ? '' : 'AND wallet_id = ?'}',
      walletId == null ? [] : [walletId],
    );
    return (r.first['s'] as num).toDouble();
  }

  Future<double> sumExpense({String? walletId}) async {
    final db = await _db;
    final r = await db.rawQuery(
      'SELECT IFNULL(SUM(amount),0) s FROM transactions WHERE is_income = 0 ${walletId == null ? '' : 'AND wallet_id = ?'}',
      walletId == null ? [] : [walletId],
    );
    return (r.first['s'] as num).toDouble();
  }
}
