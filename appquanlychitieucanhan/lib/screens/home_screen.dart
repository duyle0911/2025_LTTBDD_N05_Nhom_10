import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/expense_model.dart';
import 'transaction/add_income_screen.dart';
import 'transaction/add_expense_screen.dart';
import '../l10n/l10n_ext.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _goAddIncome(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddIncomeScreen()),
    );
  }

  void _goAddExpense(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
  }

  void _goAllTransactions(BuildContext context) {
    Navigator.pushNamed(context, '/transactions');
  }

  NumberFormat _moneyFmt(BuildContext context) {
    final lc = Localizations.localeOf(context).languageCode;
    final name = lc == 'vi' ? 'vi_VN' : 'en_US';
    return NumberFormat.currency(locale: name, symbol: '₫', decimalDigits: 0);
    // Nếu bạn muốn dùng VND tuyệt đối: NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.l10n;

    final bottomSafe = MediaQuery.of(context).viewPadding.bottom;
    const navHeight = kBottomNavigationBarHeight;
    final bottomPad = bottomSafe + navHeight + 12;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.homeOverviewTitle),
        centerTitle: true,
      ),
      body: Consumer<ExpenseModel>(
        builder: (_, m, __) {
          final fmt = _moneyFmt(context);

          // Lấy 5 giao dịch gần nhất (không hiển thị balance)
          final recent = (m.transactions.toList()
                ..sort((a, b) => b.date.compareTo(a.date)))
              .take(5)
              .toList();

          String _friendlyDate(DateTime d) {
            final df = DateFormat('dd/MM/yyyy');
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final that = DateTime(d.year, d.month, d.day);
            if (that == today) return t.today;
            return df.format(d);
          }

          Widget _recentList() {
            if (recent.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long,
                          color: Colors.blueGrey.withOpacity(0.6), size: 40),
                      const SizedBox(height: 8),
                      Text(
                        t.noTransactionsYet,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: recent.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final tr = recent[i];
                final isIncome = tr.type == 'income';
                final color = isIncome ? Colors.green : Colors.redAccent;
                final sign = isIncome ? '+' : '-';

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.12),
                      child: Icon(
                        isIncome ? Icons.south_west : Icons.north_east,
                        color: color,
                      ),
                    ),
                    title: Text(
                      tr.note.isNotEmpty ? tr.note : tr.category,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      _friendlyDate(tr.date),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Text(
                      '$sign ${fmt.format(tr.amount)}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return ListView(
            padding: EdgeInsets.only(bottom: bottomPad),
            children: [
              // Banner
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/banner_wallet.jpg',
                    height: 70,
                    width: double.maxFinite,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Hai nút thêm nhanh (KHÔNG dùng t.addIncomeShort)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () => _goAddIncome(context),
                        icon: const Icon(Icons.south_west),
                        label: Text(t.addIncomeUpper),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () => _goAddExpense(context),
                        icon: const Icon(Icons.north_east),
                        label: Text(t.addExpenseUpper),
                        style: FilledButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Header + View all
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      t.recentTransactions,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _goAllTransactions(context),
                      icon: const Icon(Icons.list_alt),
                      label: Text(t.viewAll),
                    ),
                  ],
                ),
              ),

              // Danh sách giao dịch gần đây
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _recentList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
