import 'package:flutter/material.dart';
import 'package:svg2iv_common/extensions.dart';

abstract class Preferences {
  @protected
  Preferences([this.preferences]);

  static const useDarkMode = "use_dark_mode";
  static const useMaterial3 = "use_material3";

  @visibleForTesting
  static const defaultThemeMode = ThemeMode.system;
  @visibleForTesting
  static const isMaterial3EnabledByDefault = true;

  @protected
  Map<String, String>? preferences;

  Future<Map<String, String>> getPreferences() async {
    return preferences ??= await loadPreferencesFromStorage();
  }

  @protected
  Future<Map<String, String>> loadPreferencesFromStorage();

  @mustCallSuper
  Future<void> setPreference(String key, Object value) async {
    (await getPreferences())[key] = value.toString();
  }

  Future<ThemeMode> getThemeMode() async {
    switch ((await getPreferences())[useDarkMode]) {
      case 'true':
        return ThemeMode.dark;
      case 'false':
        return ThemeMode.light;
      default:
        return defaultThemeMode;
    }
  }

  Future<bool> isMaterial3Enabled() async {
    final value = (await getPreferences())[useMaterial3];
    return !value.isNullOrEmpty
        ? value!.toLowerCase() == 'true'
        : isMaterial3EnabledByDefault;
  }

  Future<void> setDarkModeEnabled(bool enabled) async {
    await setPreference(useDarkMode, enabled);
  }

  Future<void> setMaterial3Enabled(bool enabled) async {
    await setPreference(useMaterial3, enabled);
  }
}
