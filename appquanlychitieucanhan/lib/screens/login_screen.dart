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
                      ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: usernameCtrl,
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
                  validator: validateUsername,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newPassCtrl,
                  decoration: InputDecoration(
                    labelText: t.newPassword,
                    prefixIcon: const Icon(Icons.lock_reset),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text(t.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
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
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 72,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.account_circle,
                          size: 72,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    Text(
                      t.loginTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
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
                            decoration: InputDecoration(
                              labelText: t.password,
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                tooltip:
                                    _obscure ? t.showPassword : t.hidePassword,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
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
                              ),
                              Text(t.rememberMe),
                              const Spacer(),
                              TextButton(
                                onPressed: _forgotPassword,
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
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
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
                                      t.loginButton,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(t.noAccount),
                              TextButton(
                                onPressed: _goRegister,
                                child: Text(t.registerNow),
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
    );
  }
}
