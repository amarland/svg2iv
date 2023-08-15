import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:svg2iv_common_flutter/preferences.dart';

void main() {
  final preferences = _Preferences();

  test('dark mode', () async {
    expect(await preferences.getThemeMode(), Preferences.defaultThemeMode);
    preferences.setDarkModeEnabled(true);
    expect(await preferences.getThemeMode(), ThemeMode.dark);
    preferences.setDarkModeEnabled(false);
    expect(await preferences.getThemeMode(), ThemeMode.light);
  });
  test('Material 3', () async {
    expect(
      await preferences.isMaterial3Enabled(),
      Preferences.isMaterial3EnabledByDefault,
    );
    preferences.setMaterial3Enabled(!Preferences.isMaterial3EnabledByDefault);
    expect(
      await preferences.isMaterial3Enabled(),
      !Preferences.isMaterial3EnabledByDefault,
    );
    preferences.setMaterial3Enabled(Preferences.isMaterial3EnabledByDefault);
    expect(
      await preferences.isMaterial3Enabled(),
      Preferences.isMaterial3EnabledByDefault,
    );
  });
}

class _Preferences extends Preferences {
  @override
  Future<Map<String, String>> loadPreferencesFromStorage() async =>
      HashMap<String, String>();
}
