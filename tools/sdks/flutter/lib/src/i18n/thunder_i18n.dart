import '../models/preferences.dart';
import 'default_strings.dart';

/// Resolves localized strings for Thunder UI components (spec §8.1).
///
/// Resolution order:
/// 1. Custom bundle for active locale (from [I18nPreferences.bundles])
/// 2. Custom bundle for fallback locale
/// 3. Built-in English defaults
class ThunderI18n {
  final I18nPreferences? _prefs;
  String _activeLocale;

  ThunderI18n(this._prefs) : _activeLocale = _prefs?.language ?? 'en-US';

  String get activeLocale => _activeLocale;

  void setLocale(String locale) {
    _activeLocale = locale;
  }

  String resolve(String key) {
    final bundles = _prefs?.bundles ?? {};

    final activeBundle = bundles[_activeLocale];
    if (activeBundle != null && activeBundle.containsKey(key)) {
      return activeBundle[key]!;
    }

    final fallback = _prefs?.fallbackLanguage ?? 'en-US';
    final fallbackBundle = bundles[fallback];
    if (fallbackBundle != null && fallbackBundle.containsKey(key)) {
      return fallbackBundle[key]!;
    }

    return thunderDefaultStrings[key] ?? key;
  }
}
