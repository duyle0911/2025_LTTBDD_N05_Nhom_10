import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/l10n_ext.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const route = '/change-password';
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _old = TextEditingController();
  final _new1 = TextEditingController();
  final _new2 = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _busy = false;

  Future<String?> _currentUsername() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString('username');
  }

  Future<String?> _getStoredPassword() async {
    final sp = await SharedPreferences.getInstance();
    final user = await _currentUsername();
    if (user == null) return null;
    return sp.getString('user_$user');
  }

  Future<void> _setStoredPassword(String pwd) async {
    final sp = await SharedPreferences.getInstance();
    final user = await _currentUsername();
    if (user == null) return;
    await sp.setString('user_$user', pwd);
  }

  Future<void> _submit() async {
    final t = context.l10n;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);
    try {
      final current = await _getStoredPassword();
      if (current == null || _old.text != current) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t.passwordWrongOld)));
        return;
      }
      if (_new1.text != _new2.text) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t.passwordMismatch)));
        return;
      }
      await _setStoredPassword(_new1.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.passwordUpdated)));
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _old.dispose();
    _new1.dispose();
    _new2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(t.changePassword)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _old,
                obscureText: true,
                decoration: InputDecoration(labelText: t.oldPassword),
                validator: (v) => (v == null || v.isEmpty) ? ' ' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _new1,
                obscureText: true,
                decoration: InputDecoration(labelText: t.newPassword),
                validator: (v) => (v == null || v.isEmpty) ? ' ' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _new2,
                obscureText: true,
                decoration: InputDecoration(labelText: t.confirmPassword),
                validator: (v) => (v == null || v.isEmpty) ? ' ' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(t.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
