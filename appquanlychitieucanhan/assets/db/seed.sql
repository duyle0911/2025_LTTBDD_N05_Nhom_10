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
