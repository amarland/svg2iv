import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:svg2iv_common_flutter/preferences.dart';
import 'package:svg2iv_gui/outer_world/preferences.dart';

void main() {
  test('preferences are written to/loaded from local storage', () async {
    final memoryFileSystem = MemoryFileSystem.test();
    final preferencesFile = memoryFileSystem.file('./preferences');
    var preferences = FilePreferences.internal(preferencesFile)
      ..setDarkModeEnabled(true)
      ..setDarkModeEnabled(!Preferences.isMaterial3EnabledByDefault);
    preferences = FilePreferences.internal(memoryFileSystem.file('./blank'));
    expect((await preferences.getPreferences()).isEmpty, true);
    preferences = FilePreferences.internal(preferencesFile);
    expect(await preferences.getThemeMode(), ThemeMode.dark);
    expect(
      await preferences.isMaterial3Enabled(),
      !Preferences.isMaterial3EnabledByDefault,
    );
  });
}
