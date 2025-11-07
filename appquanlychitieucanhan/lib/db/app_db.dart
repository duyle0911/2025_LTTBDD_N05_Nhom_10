import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

const String _SCHEMA_FALLBACK = r'''
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS wallets (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('cash','bank','e-wallet','other')),
  currency TEXT NOT NULL DEFAULT 'VND',
  balance REAL NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('income','expense')),
  icon TEXT,
  color_hex TEXT
);

CREATE TABLE IF NOT EXISTS transactions (
  id TEXT PRIMARY KEY,
  wallet_id TEXT NOT NULL,
  category_id TEXT NOT NULL,
  amount REAL NOT NULL CHECK (amount >= 0),
  note TEXT,
  happened_at INTEGER NOT NULL,
  is_income INTEGER NOT NULL CHECK (is_income IN (0,1)),
  created_at INTEGER NOT NULL,
  FOREIGN KEY (wallet_id) REFERENCES wallets(id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_tx_wallet_time ON transactions(wallet_id, happened_at DESC);
CREATE INDEX IF NOT EXISTS idx_tx_category_time ON transactions(category_id, happened_at DESC);
''';

const String _SEED_FALLBACK = r'''
INSERT OR IGNORE INTO wallets(id,name,type,currency,balance,created_at) VALUES
('w_cash','Tiền mặt','cash','VND',500000, strftime('%s','now')),
('w_bank','Vietcombank','bank','VND',2500000, strftime('%s','now'));

INSERT OR IGNORE INTO categories(id,name,type,icon,color_hex) VALUES
('c_food','Ăn uống','expense','restaurant','FF5A5F'),
('c_bill','Hóa đơn','expense','receipt','FFA500'),
('c_move','Di chuyển','expense','directions_bus','00B894'),
('c_salary','Lương','income','payments','2ECC71'),
('c_bonus','Thưởng','income','stars','3498DB');

INSERT OR IGNORE INTO transactions(id, wallet_id, category_id, amount, note, happened_at, is_income, created_at) VALUES
('t1','w_cash','c_food',45000,'Bánh mì + trà đá', strftime('%s','now','-1 day'),0,strftime('%s','now')),
('t2','w_bank','c_bill',120000,'Điện thoại', strftime('%s','now','-2 day'),0,strftime('%s','now')),
('t3','w_bank','c_salary',8000000,'Lương tháng 10', strftime('%s','now','-10 day'),1,strftime('%s','now'));
''';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      ffi.sqfliteFfiInit();
      databaseFactory = ffi.databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'expense_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        final okSchema = await _runAssetSqlSafe(db, 'assets/db/schema.sql',
            fallback: _SCHEMA_FALLBACK);
        final okSeed = await _runAssetSqlSafe(db, 'assets/db/seed.sql',
            fallback: _SEED_FALLBACK);
      },
    );
  }

  Future<bool> _runAssetSqlSafe(Database db, String assetPath,
      {required String fallback}) async {
    try {
      final sql = await rootBundle.loadString(assetPath);
      await _runSqlScript(db, sql);
      return true;
    } catch (_) {
      await _runSqlScript(db, fallback);
      return false;
    }
  }

  Future<void> _runSqlScript(Database db, String sql) async {
    final stmts =
        sql.split(';').map((s) => s.trim()).where((s) => s.isNotEmpty);
    await db.transaction((txn) async {
      for (final s in stmts) {
        await txn.execute(s);
      }
    });
  }
}
