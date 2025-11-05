import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/l10n_ext.dart';

class WalletItem {
  final String id;
  String name;
  String type;
  double balance;
  String currency;
  String? note;
  List<Color> gradient;

  WalletItem({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    this.note,
    required this.gradient,
  });
}

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final List<WalletItem> _wallets = [];
  String? _selectedWalletId;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String _typeCode = 'cash';
  String _currency = 'VND';

  final _typeCodes = const ['cash', 'bank', 'credit', 'savings'];
  final _currencies = const ['VND', 'USD', 'EUR', 'JPY'];

  Color get _g1 => const Color.fromARGB(255, 26, 150, 233);
  Color get _g2 => const Color.fromARGB(255, 71, 240, 130);
  Color get _g3 => const Color.fromARGB(255, 7, 143, 227);

  NumberFormat _moneyFmt(BuildContext context, String currency) {
    if (currency == 'VND') {
      final lc = Localizations.localeOf(context).languageCode;
      final name = lc == 'vi' ? 'vi_VN' : 'en_US';
      return NumberFormat.currency(locale: name, symbol: '₫', decimalDigits: 0);
    }
    return NumberFormat.simpleCurrency(name: currency);
  }

  String _typeLabel(BuildContext context, String code) {
    final t = context.l10n;
    switch (code) {
      case 'cash':
        return t.walletTypeCash;
      case 'bank':
        return t.walletTypeBank;
      case 'credit':
        return t.walletTypeCredit;
      case 'savings':
        return t.walletTypeSavings;
      default:
        return code;
    }
  }

  List<Color> _gradientFor(String code) {
    switch (code) {
      case 'cash':
        return [const Color(0xFF6EE7B7), const Color(0xFF34D399)];
      case 'bank':
        return [const Color(0xFF60A5FA), const Color(0xFF3B82F6)];
      case 'credit':
        return [const Color(0xFFA78BFA), const Color(0xFF7C3AED)];
      case 'savings':
        return [const Color(0xFFFDE68A), const Color(0xFFF59E0B)];
      default:
        return [Colors.grey, Colors.blueGrey];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _openCreateSheet() {
    final t = context.l10n;
    _nameCtrl.clear();
    _balanceCtrl.clear();
    _noteCtrl.clear();
    _typeCode = 'cash';
    _currency = 'VND';
    _openFormSheet(
      title: t.walletCreateTitle,
      onSubmit: () {
        if (_formKey.currentState?.validate() ?? false) {
          final name = _nameCtrl.text.trim();
          final init =
              double.tryParse(_balanceCtrl.text.replaceAll(',', '')) ?? 0;
          final item = WalletItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            type: _typeCode,
            balance: init,
            currency: _currency,
            note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
            gradient: _gradientFor(_typeCode),
          );
          setState(() => _wallets.insert(0, item));
          Navigator.pop(context);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(t.walletAdded)));
        }
      },
    );
  }

  void _openEditSheet(WalletItem w) {
    final t = context.l10n;
    _nameCtrl.text = w.name;
    _balanceCtrl.text = w.balance == 0 ? '' : w.balance.toStringAsFixed(0);
    _noteCtrl.text = w.note ?? '';
    _typeCode = w.type;
    _currency = w.currency;
    _openFormSheet(
      title: t.walletEditTitle,
      onSubmit: () {
        if (_formKey.currentState?.validate() ?? false) {
          setState(() {
            w.name = _nameCtrl.text.trim();
            w.type = _typeCode;
            w.currency = _currency;
            final parsed =
                double.tryParse(_balanceCtrl.text.replaceAll(',', ''));
            if (parsed != null) w.balance = parsed;
            w.note =
                _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();
            w.gradient = _gradientFor(_typeCode);
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(t.walletUpdated)));
        }
      },
    );
  }

  Future<void> _deleteWallet(WalletItem w) async {
    final t = context.l10n;
    if (w.balance != 0) {
      final msg = t.walletCannotDeleteWithBalance(
          _moneyFmt(context, w.currency).format(w.balance), w.name);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.deleteConfirmTitle),
        content: Text(t.walletDeleteConfirm(w.name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t.delete)),
        ],
      ),
    );
    if (ok == true) {
      setState(() {
        _wallets.removeWhere((e) => e.id == w.id);
        if (_selectedWalletId == w.id) _selectedWalletId = null;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.walletDeleted)));
    }
  }

  void _openSelectWalletSheet() {
    final t = context.l10n;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            Text(t.chooseWalletTitle,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            ListTile(
              leading: const Icon(Icons.all_inbox_outlined),
              title: Text(t.allWallets),
              onTap: () {
                setState(() => _selectedWalletId = null);
                Navigator.pop(context);
              },
              trailing: _selectedWalletId == null
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
            ),
            const Divider(height: 0),
            ..._wallets.map((w) => ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: Text(w.name),
                  subtitle: Text(_typeLabel(context, w.type)),
                  trailing: _selectedWalletId == w.id
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    setState(() => _selectedWalletId = w.id);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _openFormSheet({required String title, required VoidCallback onSubmit}) {
    final t = context.l10n;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: t.walletNameLabel,
                hintText: t.walletNameHint,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? t.walletNameRequired : null,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _typeCode,
              items: _typeCodes
                  .map((code) => DropdownMenuItem(
                      value: code, child: Text(_typeLabel(context, code))))
                  .toList(),
              onChanged: (s) => setState(() => _typeCode = s ?? _typeCode),
              decoration: InputDecoration(
                labelText: t.walletTypeLabel,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _balanceCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t.initialBalanceLabel,
                hintText: t.initialBalanceHint,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final n = double.tryParse(v.replaceAll(',', ''));
                if (n == null) return t.initialBalanceInvalid;
                return null;
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _currency,
              items: _currencies
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (s) => setState(() => _currency = s ?? _currency),
              decoration: InputDecoration(
                labelText: t.currencyLabel,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: t.noteOptional,
                hintText: t.walletNoteHint,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(t.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSubmit,
                    child: Text(t.save),
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Widget _walletCard(BuildContext context, WalletItem w) {
    final t = context.l10n;
    final fmt = _moneyFmt(context, w.currency);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14),
      height: 92,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: w.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle),
                child: const Icon(Icons.account_balance_wallet_outlined,
                    color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(w.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 6),
                    Text('${_typeLabel(context, w.type)} • ${w.currency}',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.92),
                            fontSize: 12)),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(fmt.format(w.balance),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert,
                        color: Colors.white.withOpacity(.95)),
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'edit', child: Text(t.edit)),
                      PopupMenuItem(value: 'delete', child: Text(t.delete)),
                    ],
                    onSelected: (v) {
                      if (v == 'edit') _openEditSheet(w);
                      if (v == 'delete') _deleteWallet(w);
                    },
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [_g1, _g2, _g3],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(t.walletTitle),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.maybePop(context),
          ),
          actions: [
            IconButton(
              tooltip: t.chooseWalletTooltip,
              onPressed: _openSelectWalletSheet,
              icon: const Icon(Icons.swap_horiz, color: Colors.white),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              if (_wallets.isEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.92),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(t.noWalletsHint),
                  ),
                )
              else
                Column(
                    children:
                        _wallets.map((w) => _walletCard(context, w)).toList()),
              Container(
                margin: const EdgeInsets.fromLTRB(14, 8, 14, 18),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.92),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(t.badgeNew,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ),
                              const SizedBox(width: 8),
                              Text(t.createWalletSectionTitle,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ]),
                            TextButton(
                              onPressed: () {
                                _nameCtrl.clear();
                                _balanceCtrl.clear();
                                _noteCtrl.clear();
                                setState(() {
                                  _typeCode = _typeCodes.first;
                                  _currency = _currencies.first;
                                });
                              },
                              child: Text(t.reset),
                            ),
                          ]),
                      const SizedBox(height: 8),
                      Form(
                        key: _formKey,
                        child: Column(children: [
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: InputDecoration(
                              labelText: t.walletNameShort,
                              hintText: t.walletNameHintShort,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? t.walletNameRequired
                                : null,
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: _typeCode,
                            items: _typeCodes
                                .map((code) => DropdownMenuItem(
                                    value: code,
                                    child: Text(_typeLabel(context, code))))
                                .toList(),
                            onChanged: (s) =>
                                setState(() => _typeCode = s ?? _typeCode),
                            decoration: InputDecoration(
                              labelText: t.walletTypeLabel,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _balanceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: t.initialBalanceLabel,
                              hintText: t.initialBalanceHint,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return null;
                              final n = double.tryParse(v.replaceAll(',', ''));
                              if (n == null) return t.initialBalanceInvalid;
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: _currency,
                            items: _currencies
                                .map((c) =>
                                    DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (s) =>
                                setState(() => _currency = s ?? _currency),
                            decoration: InputDecoration(
                              labelText: t.currencyLabel,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _noteCtrl,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: t.noteOptional,
                              hintText: t.walletNoteHint,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _openCreateSheet,
                              icon: const Icon(Icons.edit_note),
                              label: Text(t.openFullForm),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  final name = _nameCtrl.text.trim();
                                  final init = double.tryParse(_balanceCtrl.text
                                          .replaceAll(',', '')) ??
                                      0;
                                  final item = WalletItem(
                                    id: DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString(),
                                    name: name,
                                    type: _typeCode,
                                    balance: init,
                                    currency: _currency,
                                    note: _noteCtrl.text.trim().isEmpty
                                        ? null
                                        : _noteCtrl.text.trim(),
                                    gradient: _gradientFor(_typeCode),
                                  );
                                  setState(() => _wallets.insert(0, item));
                                  _nameCtrl.clear();
                                  _balanceCtrl.clear();
                                  _noteCtrl.clear();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(t.walletAdded)));
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: Text(t.createWalletButton),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ]),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openCreateSheet,
          label: Text(t.addWalletFab),
          icon: const Icon(Icons.add),
          backgroundColor: const Color(0xFF34D399),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
