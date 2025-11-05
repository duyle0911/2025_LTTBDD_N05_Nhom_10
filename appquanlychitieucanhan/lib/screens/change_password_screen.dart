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
  bool _ob1 = true;
  bool _ob2 = true;
  bool _ob3 = true;

  static const _gradStart = Color(0xFF3A7BD5);
  static const _gradEnd = Color(0xFF00D2FF);
  static const _borderSoft = Color(0xFFB3E5FC);
  static const _chip = Color(0xFF90CAF9);

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

  InputDecoration _dec(BuildContext context, String label, IconData icon,
      {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _gradStart),
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _chip),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _gradStart, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.4),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(.92),
    );
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
      appBar: AppBar(
        title: Text(t.changePassword),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_gradStart, _gradEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.fromLTRB(24, kToolbarHeight + 16, 24, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _borderSoft, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.08),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            'assets/images/change_pwd.png',
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 120,
                              color: const Color(0xFFEFF6FF),
                              alignment: Alignment.center,
                              child: const Icon(Icons.lock_reset,
                                  size: 48, color: _gradStart),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          t.changePassword,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _gradStart,
                            letterSpacing: .2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _old,
                                obscureText: _ob1,
                                decoration: _dec(
                                  context,
                                  t.oldPassword,
                                  Icons.key,
                                  suffix: IconButton(
                                    onPressed: () =>
                                        setState(() => _ob1 = !_ob1),
                                    icon: Icon(
                                      _ob1
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: _gradStart,
                                    ),
                                  ),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? t.pleaseEnterPassword
                                    : null,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _new1,
                                obscureText: _ob2,
                                decoration: _dec(
                                  context,
                                  t.newPassword,
                                  Icons.lock,
                                  suffix: IconButton(
                                    onPressed: () =>
                                        setState(() => _ob2 = !_ob2),
                                    icon: Icon(
                                      _ob2
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: _gradStart,
                                    ),
                                  ),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? t.pleaseEnterPassword
                                    : null,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _new2,
                                obscureText: _ob3,
                                decoration: _dec(
                                  context,
                                  t.confirmPassword,
                                  Icons.lock_outline,
                                  suffix: IconButton(
                                    onPressed: () =>
                                        setState(() => _ob3 = !_ob3),
                                    icon: Icon(
                                      _ob3
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: _gradStart,
                                    ),
                                  ),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? t.pleaseConfirmPassword
                                    : null,
                                onFieldSubmitted: (_) {
                                  if (!_busy) _submit();
                                },
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _busy ? null : _submit,
                                  icon: const Icon(Icons.save),
                                  label: _busy
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white),
                                        )
                                      : Text(t.save,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _gradStart,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
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
            ),
          ),
        ),
      ),
    );
  }
}
