import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:svg2iv_common/extensions.dart';

import '../util/exception_handlers.dart';

class Preferences {
  Preferences._();

  static const _useDarkMode = "use_dark_mode";
  static const _useMaterial3 = "use_material3";

  @visibleForTesting
  static const defaultThemeMode = ThemeMode.system;
  @visibleForTesting
  static const isMaterial3EnabledByDefault = false;

  static File? _file;

  @visibleForTesting
  static set file(File file) => _file = file;

  static Map<String, String>? _preferences;

  static Future<File> _getFile() async {
    if (_file != null) {
      return _file!;
    }
    return File(
      path.join(
        (await path_provider.getApplicationSupportDirectory()).path,
        'svg2iv.ini',
      ),
    );
  }

  static Future<Map<String, String>> _getPreferences() async {
    if (_preferences != null) {
      return _preferences!;
    }
    final preferences = <String, String>{};
    await runIgnoringException<FileSystemException>(() async {
      final file = await _getFile();
      if (await file.exists()) {
        for (final line in await file.readAsLines()) {
          final notATuple = line.split('=');
          if (notATuple.length == 2 && notATuple.every((s) => s.isNotEmpty)) {
            preferences[notATuple[0]] = notATuple[1];
          }
        }
      }
    });
    _preferences = preferences;
    return preferences;
  }

  static Future<void> _setPreference(String key, Object value) async {
    final preferences = await _getPreferences()
      ..[key] = value.toString();
    return runIgnoringException<FileSystemException>(() async {
      final file = await _getFile();
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      final sink = file.openWrite();
      for (final entry in preferences.entries) {
        sink.write('${entry.key}=${entry.value}');
      }
      await sink.close();
    });
  }

  static Future<ThemeMode> getThemeMode() async {
    switch ((await _getPreferences())[_useDarkMode]) {
      case 'true':
        return ThemeMode.dark;
      case 'false':
        return ThemeMode.light;
      default:
        return defaultThemeMode;
    }
  }

  static Future<bool> isMaterial3Enabled() async {
    final value = (await _getPreferences())[_useMaterial3];
    return !value.isNullOrEmpty
        ? value!.toLowerCase() == 'true'
        : isMaterial3EnabledByDefault;
  }

  static Future<void> setDarkModeEnabled(bool enabled) async {
    await _setPreference(_useDarkMode, enabled);
  }

  static Future<void> setMaterial3Enabled(bool enabled) async {
    await _setPreference(_useMaterial3, enabled);
  }
}
