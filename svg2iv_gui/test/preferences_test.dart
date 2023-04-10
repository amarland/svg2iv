import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:svg2iv_gui/outer_world/preferences.dart';

void main() {
  Preferences.file = MemoryFileSystem.test().file('./preferences.ini');

  test('dark mode', () async {
    expect(await Preferences.getThemeMode(), Preferences.defaultThemeMode);
    Preferences.setDarkModeEnabled(true);
    expect(await Preferences.getThemeMode(), ThemeMode.dark);
    Preferences.setDarkModeEnabled(false);
    expect(await Preferences.getThemeMode(), ThemeMode.light);
  });
  test('Material 3', () async {
    expect(
      await Preferences.isMaterial3Enabled(),
      Preferences.isMaterial3EnabledByDefault,
    );
    Preferences.setMaterial3Enabled(true);
    expect(await Preferences.isMaterial3Enabled(), true);
    Preferences.setMaterial3Enabled(false);
    expect(await Preferences.isMaterial3Enabled(), false);
  });
}
