import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/expense_model.dart';
import '../models/wallet_model.dart';
import '../widgets/balance_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/recent_transactions_section.dart';

import 'transaction/add_income_screen.dart';
import 'transaction/add_expense_screen.dart';
import '../screens/wallet_screen.dart';
import '../l10n/l10n_ext.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _goAddIncome(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AddIncomeScreen()));
  }

  void _goAddExpense(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
  }

  void _goAllTransactions(BuildContext context) =>
      Navigator.pushNamed(context, '/transactions');

  NumberFormat _vndFmt(BuildContext context) {
    final lc = Localizations.localeOf(context).languageCode;
    final name = lc == 'vi' ? 'vi_VN' : 'en_US';
    return NumberFormat.currency(locale: name, symbol: '₫', decimalDigits: 0);
  }

  void _ensureWalletThen(BuildContext context, VoidCallback next) {
    final wm = context.read<WalletModel>();
    if (wm.wallets.isEmpty) {
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(context.l10n.chooseWalletTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(context.l10n.noWalletsHint),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const WalletScreen()));
                  },
                  icon: const Icon(Icons.add),
                  label: Text(context.l10n.addWalletFab),
                ),
              ),
            ]),
          ),
        ),
      );
      return;
    }
    next();
  }

  void _openQuickAddSheet(BuildContext context) {
    final t = context.l10n;
    final fmt = _vndFmt(context);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSt) {
            final wm = sheetCtx.watch<WalletModel>();
            String? selectedId = wm.selectedWalletId;
            final ids = wm.wallets.map((w) => w.id).toSet();
            if (selectedId != null && !ids.contains(selectedId))
              selectedId = null;
            selectedId ??= wm.wallets.isNotEmpty ? wm.wallets.first.id : null;
            final selected = selectedId == null ? null : wm.byId(selectedId);

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet,
                          color: Theme.of(sheetCtx).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedId,
                          isExpanded: true,
                          items: [
                            for (final w in wm.wallets)
                              DropdownMenuItem(
                                  value: w.id,
                                  child: Text('${w.name} (${w.currency})'))
                          ],
                          onChanged: (v) => setSt(() => selectedId = v),
                          decoration: InputDecoration(
                            labelText: t.wallet,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (selected != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(
                                  '${t.balance}: ${fmt.format(selected.balance)}')),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: (selectedId == null)
                              ? null
                              : () {
                                  sheetCtx
                                      .read<WalletModel>()
                                      .select(selectedId);
                                  Navigator.pop(sheetCtx);
                                  _goAddIncome(context);
                                },
                          icon: const Icon(Icons.south_west),
                          label: Text(t.addIncomeTitle),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: (selectedId == null)
                              ? null
                              : () {
                                  sheetCtx
                                      .read<WalletModel>()
                                      .select(selectedId);
                                  Navigator.pop(sheetCtx);
                                  _goAddExpense(context);
                                },
                          icon: const Icon(Icons.north_east),
                          label: Text(t.addExpenseTitle),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (wm.wallets.isEmpty) ...[
                    const SizedBox(height: 12),
                    Text(t.noWalletsHint,
                        style: Theme.of(sheetCtx).textTheme.bodyMedium),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final wm = context.watch<WalletModel>();
    final wid = wm.selectedWalletId ??
        (wm.wallets.isNotEmpty ? wm.wallets.first.id : null);
    final currentWallet = wid == null ? null : wm.byId(wid);
    final walletBalance = currentWallet?.balance ?? 0.0;

    final bottomSafe = MediaQuery.of(context).viewPadding.bottom;
    const navHeight = kBottomNavigationBarHeight;
    final bottomPad = bottomSafe + navHeight + 12;

    return Scaffold(
      appBar: AppBar(title: Text(t.homeOverviewTitle), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _ensureWalletThen(context, () => _openQuickAddSheet(context)),
        icon: const Icon(Icons.add),
        label: Text(t.transactionsTitleShort),
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: bottomPad),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset('assets/images/banner_wallet.png',
                  height: 70, width: double.maxFinite, fit: BoxFit.cover),
            ),
          ),
          BalanceCard(balance: walletBalance),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () =>
                        _ensureWalletThen(context, () => _goAddIncome(context)),
                    icon: const Icon(Icons.south_west),
                    label: Text(t.addIncomeUpper),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => _ensureWalletThen(
                        context, () => _goAddExpense(context)),
                    icon: const Icon(Icons.north_east),
                    label: Text(t.addExpenseUpper),
                    style: FilledButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(t.recentTransactions,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton.icon(
                    onPressed: () => _goAllTransactions(context),
                    icon: const Icon(Icons.list_alt),
                    label: Text(t.viewAll)),
              ],
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Consumer<ExpenseModel>(
                  builder: (_, m, __) => SummaryCard(expense: m))),
          const SizedBox(height: 8),
          Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Consumer<ExpenseModel>(
                  builder: (_, m, __) =>
                      RecentTransactionsSection(expense: m))),
        ],
      ),
    );
  }
}
