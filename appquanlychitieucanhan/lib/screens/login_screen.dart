import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n_ext.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();

  bool _isLoading = false;
  bool _obscure = true;
  bool _rememberMe = true;

  final Color _primary = const Color(0xFF00D2FF);
  final Color _primaryDark = const Color.fromARGB(255, 4, 134, 141);
  final Color _primarySoft = const Color.fromARGB(255, 12, 216, 148);
  final Color _chip = const Color.fromARGB(255, 12, 235, 220);

  @override
  void initState() {
    super.initState();
    _prefillUsername();
  }

  Future<void> _prefillUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString('last_username');
    if (last != null && mounted) _username.text = last;
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final t = context.l10n;
    final username = _username.text.trim();
    final password = _password.text.trim();

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('user_$username');
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    if (savedPassword == null || savedPassword != password) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.invalidCredentials)),
      );
      return;
    }

    await prefs.setString('username', username);
    if (_rememberMe) {
      await prefs.setString('last_username', username);
    } else {
      await prefs.remove('last_username');
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  void _goRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  Future<void> _forgotPassword() async {
    final t = context.l10n;

    final formKey = GlobalKey<FormState>();
    final usernameCtrl = TextEditingController(text: _username.text.trim());
    final newPassCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    String? validateUsername(String? v) {
      final s = (v ?? '').trim();
      if (s.isEmpty) return t.pleaseEnterUsername;
      if (s.length < 3) return t.usernameMinLen;
      if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(s)) return t.usernameRules;
      return null;
    }

    String? validatePassword(String? v) {
      final s = (v ?? '');
      if (s.isEmpty) return t.pleaseEnterPassword;
      if (s.length < 6) return t.passwordMinLen;
      if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{6,}$').hasMatch(s)) {
        return t.passwordRecommendLettersDigits;
      }
      return null;
    }

    String? validateConfirm(String? v) {
      if (v == null || v.isEmpty) return t.pleaseConfirmPassword;
      if (v != newPassCtrl.text) return t.passwordMismatch;
      return null;
    }

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (ctx) {
        final inset = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + inset),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.forgotPasswordQ,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _primaryDark,
                      ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: usernameCtrl,
                  decoration: InputDecoration(
                    labelText: t.username,
                    prefixIcon: Icon(Icons.person, color: _primaryDark),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _chip),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _primaryDark, width: 1.4),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  validator: validateUsername,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newPassCtrl,
                  decoration: InputDecoration(
                    labelText: t.newPassword,
                    prefixIcon: Icon(Icons.lock_reset, color: _primaryDark),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _chip),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _primaryDark, width: 1.4),
                    ),
                  ),
                  obscureText: true,
                  validator: validatePassword,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmCtrl,
                  decoration: InputDecoration(
                    labelText: t.confirmPassword,
                    prefixIcon: Icon(Icons.lock_outline, color: _primaryDark),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _chip),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _primaryDark, width: 1.4),
                    ),
                  ),
                  obscureText: true,
                  validator: validateConfirm,
                  onFieldSubmitted: (_) => Navigator.of(ctx).pop(true),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primaryDark,
                          side: BorderSide(color: _primaryDark),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text(t.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            Navigator.of(ctx).pop(true);
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: Text(t.save),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (ok != true || !mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final uname = usernameCtrl.text.trim();
    if (!prefs.containsKey('user_$uname')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.invalidCredentials)),
      );
      return;
    }

    await prefs.setString('user_$uname', newPassCtrl.text);

    if (!mounted) return;

    if (_username.text.trim().isEmpty) {
      _username.text = uname;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.passwordUpdated)),
    );
  }

  InputDecoration _inputDecoration(
      BuildContext context, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _primaryDark),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _chip),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryDark, width: 1.4),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(.92),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.85),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.08),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: _primarySoft, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: _primarySoft.withOpacity(.35),
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 56,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.account_circle,
                              size: 56,
                              color: _primaryDark,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        t.loginTitle,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _primaryDark,
                          letterSpacing: .2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _username,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.username],
                              decoration: _inputDecoration(
                                  context, t.username, Icons.person),
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                              ],
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? t.pleaseEnterUsername
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _password,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              decoration: _inputDecoration(
                                      context, t.password, Icons.lock)
                                  .copyWith(
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: _primaryDark,
                                  ),
                                  tooltip: _obscure
                                      ? t.showPassword
                                      : t.hidePassword,
                                ),
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? t.pleaseEnterPassword
                                  : null,
                              onFieldSubmitted: (_) {
                                if (!_isLoading) _login();
                              },
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) =>
                                      setState(() => _rememberMe = v ?? true),
                                  activeColor: _primaryDark,
                                  checkColor: Colors.white,
                                  side: BorderSide(color: _chip),
                                ),
                                Text('Ghi nhớ',
                                    style: TextStyle(color: _primaryDark)),
                                const Spacer(),
                                TextButton(
                                  onPressed: _forgotPassword,
                                  style: TextButton.styleFrom(
                                      foregroundColor: _primaryDark),
                                  child: Text(t.forgotPasswordQ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  backgroundColor: _primaryDark,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Đăng nhập',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Chưa có tài khoản?',
                                    style: TextStyle(color: _primaryDark)),
                                TextButton(
                                  onPressed: _goRegister,
                                  style: TextButton.styleFrom(
                                      foregroundColor: _primary),
                                  child: const Text('Đăng ký ngay'),
                                ),
                              ],
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
    );
  }
}
