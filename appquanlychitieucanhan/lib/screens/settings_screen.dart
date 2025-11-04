import 'package:flutter/material.dart';
import '../l10n/l10n_ext.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatelessWidget {
  static const route = '/settings';
  final Future<void> Function(String code) onPickLocale;

  const SettingsScreen({super.key, required this.onPickLocale});

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final currentCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(t.language,
                style: Theme.of(context).textTheme.titleMedium),
          ),
          _LangTile(
            flag: '🇬🇧',
            label: t.english,
            selected: currentCode == 'en',
            onTap: () => onPickLocale('en'),
          ),
          const Divider(height: 0),
          _LangTile(
            flag: '🇻🇳',
            label: t.vietnamese,
            selected: currentCode == 'vi',
            onTap: () => onPickLocale('vi'),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: Text(t.changePassword),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                Navigator.pushNamed(context, ChangePasswordScreen.route),
          ),
        ],
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangTile({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(flag, style: const TextStyle(fontSize: 18)),
      ),
      title: Text(label),
      trailing: selected ? const Icon(Icons.check_circle) : null,
      onTap: onTap,
    );
  }
}
