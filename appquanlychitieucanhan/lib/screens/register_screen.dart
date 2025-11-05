import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import '../l10n/l10n_ext.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _isLoading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

  final Color _primary = const Color(0xFF00D2FF);
  final Color _primaryDark = const Color(0xFF3A7BD5);
  final Color _primarySoft = const Color.fromARGB(255, 9, 155, 72);
  final Color _chip = const Color(0xFF90CAF9);

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _validateUsername(String? v) {
    final t = context.l10n;
    final s = (v ?? '').trim();
    if (s.isEmpty) return t.pleaseEnterUsername;
    if (s.length < 3) return t.usernameMinLen;
    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(s)) return t.usernameRules;
    return null;
  }

  String? _validatePassword(String? v) {
    final t = context.l10n;
    final s = (v ?? '');
    if (s.isEmpty) return t.pleaseEnterPassword;
    if (s.length < 6) return t.passwordMinLen;
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{6,}$').hasMatch(s)) {
      return t.passwordRecommendLettersDigits;
    }
    return null;
  }

  String? _validateConfirm(String? v) {
    final t = context.l10n;
    if (v == null || v.isEmpty) return t.pleaseConfirmPassword;
    if (v != _password.text) return t.passwordMismatch;
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final username = _username.text.trim();
    final password = _password.text;
    final t = context.l10n;

    if (prefs.containsKey('user_$username')) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t.usernameExists)));
      }
      setState(() => _isLoading = false);
      return;
    }

    await prefs.setString('user_$username', password);

    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(t.registerSuccess)));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _goLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            'assets/images/register.png',
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.person_add_alt_1,
                              size: 56,
                              color: _primaryDark,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        t.registerTitle,
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
                              autofillHints: const [AutofillHints.newUsername],
                              decoration:
                                  _inputDecoration(t.username, Icons.person),
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                              ],
                              validator: _validateUsername,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _password,
                              obscureText: _obscure1,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.newPassword],
                              decoration:
                                  _inputDecoration(t.password, Icons.lock)
                                      .copyWith(
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscure1 = !_obscure1),
                                  icon: Icon(
                                    _obscure1
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: _primaryDark,
                                  ),
                                  tooltip: _obscure1
                                      ? t.showPassword
                                      : t.hidePassword,
                                ),
                              ),
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _confirm,
                              obscureText: _obscure2,
                              textInputAction: TextInputAction.done,
                              decoration: _inputDecoration(
                                      t.confirmPassword, Icons.lock_outline)
                                  .copyWith(
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscure2 = !_obscure2),
                                  icon: Icon(
                                    _obscure2
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: _primaryDark,
                                  ),
                                  tooltip: _obscure2
                                      ? t.showPassword
                                      : t.hidePassword,
                                ),
                              ),
                              validator: _validateConfirm,
                              onFieldSubmitted: (_) {
                                if (!_isLoading) _register();
                              },
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryDark,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
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
                                    : Text(
                                        t.registerButton,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(t.haveAccount,
                                    style: TextStyle(color: _primaryDark)),
                                TextButton(
                                  onPressed: _isLoading ? null : _goLogin,
                                  style: TextButton.styleFrom(
                                      foregroundColor: _primary),
                                  child: Text(t.loginButton),
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
