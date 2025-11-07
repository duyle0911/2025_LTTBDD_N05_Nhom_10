import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/wallet_model.dart';
import '../l10n/l10n_ext.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  Color get _blue => const Color.fromARGB(255, 26, 150, 233);
  Color get _purple => const Color.fromARGB(255, 71, 240, 130);
  Color get _red => const Color.fromARGB(255, 7, 143, 227);

  final List<String> _types = const ['cash', 'bank', 'credit', 'savings'];

  String _toCode(String raw) {
    final s = raw.trim().toLowerCase();
    switch (s) {
      case 'cash':
      case 'bank':
      case 'credit':
      case 'savings':
        return s;

      case 'tiền mặt':
        return 'cash';
      case 'ngân hàng':
        return 'bank';
      case 'thẻ tín dụng':
        return 'credit';
      case 'tiết kiệm':
        return 'savings';
      default:
        return 'savings';
    }
  }

  String _ensureInTypes(String v) => _types.contains(v) ? v : _types.first;

  NumberFormat _fmtVND() {
    final lc = Localizations.localeOf(context).languageCode;
    final name = lc == 'vi' ? 'vi_VN' : 'en_US';
    return NumberFormat.currency(locale: name, symbol: '₫', decimalDigits: 0);
  }

  Color _fromHex(String hex) {
    var h = hex.replaceAll('#', '');
    if (h.length == 3) h = h.split('').map((c) => '$c$c').join();
    if (h.length == 6) h = 'FF$h';
    return Color(int.parse(h, radix: 16));
  }

  Color _onColor(Color c) =>
      ThemeData.estimateBrightnessForColor(c) == Brightness.dark
          ? Colors.white
          : Colors.black87;

  List<Color> _cardGradient(Color base) => [
        base.withOpacity(.95),
        base.withOpacity(.78),
      ];

  String _typeLabel(String codeOrLegacy) {
    final t = context.l10n;
    switch (_toCode(codeOrLegacy)) {
      case 'cash':
        return t.walletTypeCash;
      case 'bank':
        return t.walletTypeBank;
      case 'credit':
        return t.walletTypeCredit;
      case 'savings':
      default:
        return t.walletTypeSavings;
    }
  }

  IconData _iconForType(String codeOrLegacy) {
    switch (_toCode(codeOrLegacy)) {
      case 'cash':
        return Icons.account_balance_wallet;
      case 'bank':
        return Icons.account_balance;
      case 'credit':
        return Icons.credit_card;
      case 'savings':
      default:
        return Icons.savings;
    }
  }

  String _headerSelection = 'all';

  Future<void> _showWalletForm(BuildContext context, {WalletItem? edit}) async {
    final t = context.l10n;
    final wm = context.read<WalletModel>();

    final name = TextEditingController(text: edit?.name ?? '');

    String type = _ensureInTypes(_toCode(edit?.type ?? _types.first));

    final balance = TextEditingController(
      text: edit != null
          ? _fmtVND().format(edit.balance).replaceAll(RegExp(r'[^\d,.]'), '')
          : '',
    );
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final viewInsets = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + viewInsets),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  edit == null ? t.walletCreate : t.walletEdit,
                  style: Theme.of(ctx)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: t.fieldWalletName,
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? t.inputWalletName
                      : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: type, // luôn là code hợp lệ
                  items: _types
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(_typeLabel(e)),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => type = _ensureInTypes(v ?? type)),
                  decoration: InputDecoration(
                    labelText: t.fieldWalletType,
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: balance,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: t.fieldBalanceVnd,
                    hintText: '0',
                    prefixIcon:
                        const Icon(Icons.account_balance_wallet_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final raw = v.replaceAll(RegExp(r'[^0-9.]'), '');
                    final d = double.tryParse(raw);
                    if (d == null) return t.invalidBalance;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      final raw = balance.text.isEmpty
                          ? 0.0
                          : double.parse(
                              balance.text.replaceAll(RegExp(r'[^0-9.]'), ''));
                      if (edit == null) {
                        final id = wm.addWallet(
                          name: name.text,
                          type: type,
                          initialBalance: raw,
                        );
                        wm.select(id);
                      } else {
                        wm.updateWallet(
                          edit.id,
                          name: name.text,
                          type: type,
                          balance: raw,
                        );
                        wm.select(edit.id);
                      }
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.save_rounded),
                    label: Text(edit == null ? t.create : t.saveChanges),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WalletItem w) async {
    final t = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.deleteWallet),
        content: Text(t.deleteWalletConfirm(w.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.delete),
          ),
        ],
      ),
    );
    if (ok == true) context.read<WalletModel>().removeWallet(w.id);
  }

  final _newName = TextEditingController();
  final _newBalance = TextEditingController(text: '');
  String _newType = 'savings';
  final _newDesc = TextEditingController();

  void _resetInlineForm() {
    setState(() {
      _newName.clear();
      _newType = 'savings';
      _newBalance.clear();
      _newDesc.clear();
    });
  }

  double _parseBalance(String text) {
    if (text.trim().isEmpty) return 0;
    final raw = text.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(raw) ?? 0;
  }

  void _createNewWalletInline() {
    final t = context.l10n;
    final name = _newName.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.inputWalletName)));
      return;
    }
    final initBal = _parseBalance(_newBalance.text);
    final wm = context.read<WalletModel>();
    final id = wm.addWallet(
      name: name,
      type: _ensureInTypes(_newType),
      initialBalance: initBal,
    );
    wm.select(id);
    _resetInlineForm();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.createdWallet(_fmtVND().format(initBal)))),
    );
  }

  Future<void> _openWalletChooser(BuildContext context) async {
    final t = context.l10n;
    final wm = context.read<WalletModel>();
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.dashboard_customize_outlined),
              title: Text(t.allWallets),
              onTap: () {
                setState(() => _headerSelection = 'all');
                Navigator.pop(ctx);
              },
            ),
            const Divider(height: 1),
            ...wm.wallets.map(
              (w) => ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: Text(w.name),
                subtitle: Text(_typeLabel(w.type)),
                trailing: Text(_fmtVND().format(w.balance)),
                onTap: () {
                  setState(() => _headerSelection = w.id);
                  wm.select(w.id);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final wm = context.watch<WalletModel>();
    final fmt = _fmtVND();

    final double headerBalance = _headerSelection == 'all'
        ? wm.wallets.fold<double>(0, (s, w) => s + (w.balance))
        : (wm.byId(_headerSelection)?.balance ?? 0.0);

    final String headerLabel = _headerSelection == 'all'
        ? t.allWallets
        : (wm.byId(_headerSelection)?.name ?? t.allWallets);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_blue, _purple, _red],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(t.walletManageTitle),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              tooltip: t.createWalletPopup,
              onPressed: () => _showWalletForm(context),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.95),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_balance,
                              color: Colors.black54),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t.totalWallets(wm.wallets.length),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _openWalletChooser(context),
                            icon: const Icon(Icons.arrow_drop_down),
                            label: Text(headerLabel),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_outlined,
                              size: 18, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text(
                            '${t.balance}: ${fmt.format(headerBalance)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          if (_headerSelection != 'all')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(.06),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      size: 16, color: Colors.green),
                                  const SizedBox(width: 6),
                                  Text(t.selected),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                for (int i = 0; i < wm.wallets.length; i++) ...[
                  _buildWalletItem(wm.wallets[i], fmt),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.92),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              t.newBadge,
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              t.createWalletInlineTitle,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                          ),
                          TextButton(
                            onPressed: _resetInlineForm,
                            child: Text(t.reset),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _newName,
                        decoration: InputDecoration(
                          labelText: t.fieldWalletName,
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _ensureInTypes(_newType),
                        items: _types
                            .map((e) => DropdownMenuItem(
                                value: e, child: Text(_typeLabel(e))))
                            .toList(),
                        onChanged: (v) => setState(
                            () => _newType = _ensureInTypes(v ?? _newType)),
                        decoration: InputDecoration(
                          labelText: t.fieldWalletTypeAccount,
                          prefixIcon: const Icon(Icons.category_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _newBalance,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: t.fieldInitialBalance,
                          hintText: '0',
                          suffixText: 'VND',
                          prefixIcon:
                              const Icon(Icons.account_balance_wallet_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: 'VND',
                        items: const [
                          DropdownMenuItem(value: 'VND', child: Text('VND')),
                        ],
                        onChanged: null,
                        decoration: InputDecoration(
                          labelText: t.fieldCurrency,
                          prefixIcon: const Icon(Icons.payments_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _newDesc,
                        decoration: InputDecoration(
                          labelText: t.fieldDescriptionOptional,
                          prefixIcon: const Icon(Icons.notes_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: _createNewWalletInline,
                          icon: const Icon(Icons.add),
                          label: Text(t.createWalletCta),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF00B894),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletItem(WalletItem w, NumberFormat fmt) {
    final t = context.l10n;
    final wm = context.watch<WalletModel>();
    final isSelected = wm.selectedWalletId == w.id;
    final primary = _fromHex(w.colorHex);
    final onCard = _onColor(primary);

    final code = _toCode(w.type);

    return InkWell(
      onTap: () {
        wm.select(w.id);
        setState(() => _headerSelection = w.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _cardGradient(primary),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white.withOpacity(.9) : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          leading: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(.18),
            child: Icon(_iconForType(code), color: Colors.white),
          ),
          title: Text(
            w.name,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: onCard,
            ),
          ),
          subtitle: Text(
            '${_typeLabel(code)} • VND',
            style: TextStyle(color: onCard.withOpacity(.85)),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                fmt.format(w.balance),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: onCard,
                ),
              ),
              const SizedBox(width: 6),
              PopupMenuButton<String>(
                color: Colors.white,
                onSelected: (value) {
                  if (value == 'select') {
                    wm.select(w.id);
                    setState(() => _headerSelection = w.id);
                  } else if (value == 'edit') {
                    _showWalletForm(context, edit: w);
                  } else if (value == 'delete') {
                    _confirmDelete(context, w);
                  }
                },
                itemBuilder: (ctx) => [
                  if (!isSelected)
                    PopupMenuItem(
                      value: 'select',
                      child: Text(t.chooseThisWallet),
                    ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(t.edit),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(t.delete),
                  ),
                ],
                icon: Icon(Icons.more_vert, color: onCard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
