import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n {
    final l = AppLocalizations.of(this);
    assert(l != null, 'AppLocalizations not found in context');
    return l!;
  }
}
