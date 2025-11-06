import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/wallet_model.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  Color get _blue => const Color.fromARGB(255, 26, 150, 233);
  Color get _purple => const Color.fromARGB(255, 71, 240, 130);
  Color get _red => const Color.fromARGB(255, 7, 143, 227);

  final _typesVN = const ['Tiền mặt', 'Ngân hàng', 'Thẻ tín dụng', 'Tiết kiệm'];

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

  Future<void> _showWalletForm(BuildContext context, {WalletItem? edit}) async {
    final wm = context.read<WalletModel>();
    final name = TextEditingController(text: edit?.name ?? '');
    String type = edit?.type ?? _typesVN.first;
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
                  edit == null ? 'Tạo ví' : 'Chỉnh sửa ví',
                  style: Theme.of(ctx)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: 'Tên ví',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nhập tên ví' : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: type,
                  items: _typesVN
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => type = v ?? _typesVN.first),
                  decoration: InputDecoration(
                    labelText: 'Loại ví',
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
                    labelText: 'Số dư (VND)',
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
                    if (d == null) return 'Số dư không hợp lệ';
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
                    label: Text(edit == null ? 'Tạo ví' : 'Lưu thay đổi'),
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa ví'),
        content: Text('Bạn có chắc muốn xóa ví "${w.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok == true) context.read<WalletModel>().removeWallet(w.id);
  }

  IconData _iconForType(String vnType) {
    switch (vnType) {
      case 'Tiền mặt':
        return Icons.account_balance_wallet;
      case 'Ngân hàng':
        return Icons.account_balance;
      case 'Thẻ tín dụng':
        return Icons.credit_card;
      case 'Tiết kiệm':
        return Icons.savings;
      default:
        return Icons.account_balance_wallet;
    }
  }

  final _newName = TextEditingController();
  final _newBalance = TextEditingController(text: '');
  String _newType = 'Tiết kiệm';
  final _newDesc = TextEditingController();

  void _resetInlineForm() {
    setState(() {
      _newName.clear();
      _newType = 'Tiết kiệm';
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
    final name = _newName.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nhập tên ví')));
      return;
    }
    final initBal = _parseBalance(_newBalance.text);
    final wm = context.read<WalletModel>();
    final id = wm.addWallet(
      name: name,
      type: _newType,
      initialBalance: initBal,
    );
    wm.select(id);
    _resetInlineForm();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã tạo ví mới (${_fmtVND().format(initBal)})')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wm = context.watch<WalletModel>();
    final fmt = _fmtVND();

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
          title: const Text('Quản lý ví'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              tooltip: 'Tạo ví (popup)',
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
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance, color: Colors.black54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Tổng số ví: ${wm.wallets.length}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      if (wm.selectedWalletId != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.06),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle,
                                  size: 16, color: Colors.green),
                              SizedBox(width: 6),
                              Text('Đang chọn'),
                            ],
                          ),
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
                            child: const Text('NEW',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text('Tạo ví mới',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 16)),
                          ),
                          TextButton(
                            onPressed: _resetInlineForm,
                            child: const Text('Đặt lại'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _newName,
                        decoration: InputDecoration(
                          labelText: 'Tên ví',
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _newType,
                        items: _typesVN
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _newType = v ?? _newType),
                        decoration: InputDecoration(
                          labelText: 'Loại tài khoản',
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
                          labelText: 'Số dư',
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
                          labelText: 'Đơn vị tiền tệ',
                          prefixIcon: const Icon(Icons.payments_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _newDesc,
                        decoration: InputDecoration(
                          labelText: 'Mô tả (tuỳ chọn)',
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
                          label: const Text('Tạo ví'),
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
    final wm = context.watch<WalletModel>();
    final isSelected = wm.selectedWalletId == w.id;
    final primary = _fromHex(w.colorHex);
    final onCard = _onColor(primary);

    return InkWell(
      onTap: () => wm.select(w.id),
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
            child: Icon(_iconForType(w.type), color: Colors.white),
          ),
          title: Text(
            w.name,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: onCard,
            ),
          ),
          subtitle: Text(
            '${w.type} • VND',
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
                  } else if (value == 'edit') {
                    _showWalletForm(context, edit: w);
                  } else if (value == 'delete') {
                    _confirmDelete(context, w);
                  }
                },
                itemBuilder: (ctx) => [
                  if (!isSelected)
                    const PopupMenuItem(
                      value: 'select',
                      child: Text('Chọn ví này'),
                    ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Chỉnh sửa'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Xóa'),
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
