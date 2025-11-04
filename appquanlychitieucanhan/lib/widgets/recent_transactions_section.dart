import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../models/expense_model.dart';
import '../l10n/l10n_ext.dart';

class RecentTransactionsSection extends StatelessWidget {
  final ExpenseModel expense;
  const RecentTransactionsSection({super.key, required this.expense});

  NumberFormat _moneyFmt(BuildContext context) {
    final lc = Localizations.localeOf(context).languageCode;
    final name = lc == 'vi' ? 'vi_VN' : 'en_US';
    return NumberFormat.currency(locale: name, symbol: '₫', decimalDigits: 0);
  }

  String _friendlyDate(BuildContext context, DateTime d) {
    final t = context.l10n;
    final df = DateFormat('dd/MM/yyyy');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);
    if (that == today) return t.today;
    return df.format(d);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final fmt = _moneyFmt(context);

    final recent = (expense.transactions.toList()
          ..sort((a, b) => b.date.compareTo(a.date)))
        .take(5)
        .toList();

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                t.recentTransactions,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${recent.length}',
                  style: const TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/transactions'),
                child: Text(t.viewAll),
              ),
            ],
          ),
        ),
        ListView.separated(
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
                  _friendlyDate(context, tr.date),
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
                onTap: () async {
                  final text = '$sign ${fmt.format(tr.amount)}';
                  await Clipboard.setData(ClipboardData(text: text));

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.copiedBalance(text))),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
