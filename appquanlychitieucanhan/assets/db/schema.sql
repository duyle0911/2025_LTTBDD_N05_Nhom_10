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
