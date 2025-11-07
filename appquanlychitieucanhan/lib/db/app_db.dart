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
  type TEXT NOT NULL CHECK (type IN ('cash','bank','credit','savings','other')),
  currency TEXT NOT NULL DEFAULT 'VND',
  color_hex TEXT DEFAULT '#1976D2',
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
INSERT OR IGNORE INTO wallets(id,name,type,currency,color_hex,balance,created_at) VALUES
('w_cash','Tiền mặt','cash','VND','#1976D2',0, strftime('%s','now')),
('w_bank','Ngân hàng','bank','VND','#90CAF9',0, strftime('%s','now'));

INSERT OR IGNORE INTO categories(id,name,type,icon,color_hex) VALUES
('c_food','Ăn uống','expense','restaurant','E91E63'),
('c_move','Đi lại','expense','directions_bus','9C27B0'),
('c_bill','Hóa đơn','expense','receipt','7C4DFF'),
('c_shop','Mua sắm','expense','shopping_bag','3F51B5'),
('c_other_exp','Khác','expense','category','607D8B'),
('c_salary','Lương','income','payments','2E7D32'),
('c_bonus','Thưởng','income','stars','00BCD4'),
('c_other_inc','Khác','income','attach_money','607D8B');
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
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: (db, version) async {
        final okSchema = await _runAssetSqlSafe(db, 'assets/db/schema.sql',
            fallback: _SCHEMA_FALLBACK);
        if (!okSchema) {}
        await _runAssetSqlSafe(db, 'assets/db/seed.sql',
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
