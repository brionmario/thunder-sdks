/// Preferences for UI customization — theme and i18n (spec §5.3).
/// Applies only when using Thunder UI components; ignored by the protocol layer.
class ThunderPreferences {
  final ThemePreferences? theme;
  final I18nPreferences? i18n;

  /// When true, resolve theme from the Thunder Flow Meta API (GET /flow/meta).
  final bool resolveFromMeta;

  const ThunderPreferences({
    this.theme,
    this.i18n,
    this.resolveFromMeta = false,
  });

  Map<String, dynamic> toMap() => {
        if (theme != null) 'theme': theme!.toMap(),
        if (i18n != null) 'i18n': i18n!.toMap(),
        'resolveFromMeta': resolveFromMeta,
      };
}

class ThemePreferences {
  /// "light", "dark", or "auto"
  final String? mode;
  final bool inheritFromBranding;

  /// Partial override of the default theme token set (colors, typography, etc.)
  final Map<String, dynamic> overrides;

  const ThemePreferences({
    this.mode,
    this.inheritFromBranding = false,
    this.overrides = const {},
  });

  Map<String, dynamic> toMap() => {
        if (mode != null) 'mode': mode,
        'inheritFromBranding': inheritFromBranding,
        'overrides': overrides,
      };
}

class I18nPreferences {
  /// Hard locale override, e.g. "fr-FR". Bypasses all detection when set.
  final String? language;

  /// Locale used when translations are unavailable. Defaults to "en-US".
  final String fallbackLanguage;

  /// Custom translation bundles: locale → (key → string).
  final Map<String, Map<String, String>> bundles;

  /// Key used to persist language selection. On mobile, stored in-memory only
  /// (no cookie/localStorage). Use [language] to lock a locale persistently.
  final String storageKey;

  const I18nPreferences({
    this.language,
    this.fallbackLanguage = 'en-US',
    this.bundles = const {},
    this.storageKey = 'thunder-i18n-language',
  });

  Map<String, dynamic> toMap() => {
        if (language != null) 'language': language,
        'fallbackLanguage': fallbackLanguage,
        'bundles': bundles,
        'storageKey': storageKey,
      };
}
