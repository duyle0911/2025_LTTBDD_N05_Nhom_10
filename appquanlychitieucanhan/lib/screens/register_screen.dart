import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.usernameExists)),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    await prefs.setString('user_$username', password);

    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.registerSuccess)),
    );

    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.l10n;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
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
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person_add,
                            size: 72,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      t.registerTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
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
                            decoration: InputDecoration(
                              labelText: t.username,
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
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
                            decoration: InputDecoration(
                              labelText: t.password,
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure1 = !_obscure1),
                                icon: Icon(
                                  _obscure1
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                tooltip:
                                    _obscure1 ? t.showPassword : t.hidePassword,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _confirm,
                            obscureText: _obscure2,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: t.confirmPassword,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure2 = !_obscure2),
                                icon: Icon(
                                  _obscure2
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                tooltip:
                                    _obscure2 ? t.showPassword : t.hidePassword,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
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
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushReplacementNamed(context, '/'),
                            child: Text(t.loginButton),
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
    );
  }
}
