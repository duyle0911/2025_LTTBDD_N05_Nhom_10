import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense_model.dart';
import '../models/wallet_model.dart';
import 'login_screen.dart';
import '../l10n/l10n_ext.dart';
import 'change_password_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Color get _primary => const Color.fromARGB(255, 34, 181, 249);
  Color get _primaryDark => const Color.fromARGB(255, 36, 194, 242);
  Color get _primarySoft => const Color.fromARGB(255, 20, 223, 145);
  Color get _chip => const Color.fromARGB(255, 5, 113, 229);

  Future<void> _confirmLogout(BuildContext context) async {
    final t = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.logoutTitle),
        content: Text(t.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.logout),
          ),
        ],
      ),
    );
    if (ok == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('username');
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  NumberFormat _currencyFmt(BuildContext context) {
    final lc = Localizations.localeOf(context).languageCode;
    final name = lc == 'vi' ? 'vi_VN' : 'en_US';
    return NumberFormat.currency(locale: name, symbol: '₫', decimalDigits: 0);
  }

  @override
  Widget build(BuildContext context) {
    final m = context.watch<ExpenseModel>();
    final wm = context.watch<WalletModel>();
    final currency = _currencyFmt(context);
    final t = context.l10n;

    final wid = wm.selectedWalletId ??
        (wm.wallets.isNotEmpty ? wm.wallets.first.id : null);
    final walletBal = wid == null ? 0.0 : (wm.byId(wid)?.balance ?? 0.0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(t.tabProfile),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primary, const Color(0xFF5E7BEF), _primarySoft],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primary, const Color(0xFF5E7BEF), _primarySoft],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _chip.withOpacity(.35),
                      Colors.white.withOpacity(.2)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Image.asset(
                  'assets/images/profile_banner.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.white.withOpacity(.18),
                    alignment: Alignment.center,
                    child: Icon(Icons.image,
                        size: 40, color: Colors.white.withOpacity(.9)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.88),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _chip.withOpacity(.5), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: _primaryDark.withOpacity(.15),
                    backgroundImage:
                        const AssetImage('assets/images/user_avatar.png'),
                    onBackgroundImageError: (_, __) {},
                    child: Icon(Icons.person, size: 44, color: _primaryDark),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FutureBuilder<SharedPreferences>(
                      future: SharedPreferences.getInstance(),
                      builder: (context, snap) {
                        final username = snap.hasData
                            ? (snap.data!.getString('username') ??
                                t.userDefaultName)
                            : t.userDefaultName;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: _primaryDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              t.appTagline,
                              style: TextStyle(
                                  color: Colors.black.withOpacity(.55)),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: t.totalIncome,
                    value: currency.format(m.income),
                    icon: Icons.trending_up,
                    color: const Color(0xFF2E7D32),
                    bg: Colors.white.withOpacity(.88),
                    border: _chip.withOpacity(.5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    label: t.totalExpense,
                    value: currency.format(m.expense),
                    icon: Icons.trending_down,
                    color: Colors.redAccent,
                    bg: Colors.white.withOpacity(.88),
                    border: _chip.withOpacity(.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _BalanceTile(
              title: t.currentBalance,
              subtitle: t.incomeMinusExpense,
              balance: currency.format(walletBal),
              primary: _primaryDark,
              chip: _chip,
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.88),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _chip.withOpacity(.5), width: 1),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.lock_reset, color: _primaryDark),
                    title: Text(t.changePassword),
                    subtitle: Text(t.changePasswordSubtitle),
                    onTap: () => Navigator.pushNamed(
                        context, ChangePasswordScreen.route),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.settings, color: _primaryDark),
                    title: Text(t.settings),
                    onTap: () =>
                        Navigator.pushNamed(context, SettingsScreen.route),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Đăng xuất',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;
  final Color border;
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(color: Colors.black.withOpacity(.55))),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String balance;
  final Color primary;
  final Color chip;
  const _BalanceTile({
    required this.title,
    required this.subtitle,
    required this.balance,
    required this.primary,
    required this.chip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: chip.withOpacity(.5), width: 1),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primary.withOpacity(.12),
          child: Icon(Icons.account_balance_wallet, color: primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          balance,
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
