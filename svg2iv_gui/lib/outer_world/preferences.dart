import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

import '../util/exception_handlers.dart';

const _useDarkMode = "use_dark_mode";
const _useMaterial3 = "use_material3";

File? _file;

Map<String, String>? _preferences;

Future<File> _getFile() async {
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

Future<Map<String, String>> _getPreferences() async {
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

Future<void> _setPreference(String key, Object value) async {
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

Future<ThemeMode> getThemeMode() async {
  switch ((await _getPreferences())[_useDarkMode]) {
    case 'true':
      return ThemeMode.dark;
    case 'false':
      return ThemeMode.light;
    default:
      return ThemeMode.system;
  }
}

Future<bool> isMaterial3Enabled() async =>
    (await _getPreferences())[_useMaterial3]?.toLowerCase() == 'true';

Future<void> setDarkModeEnabled(bool enabled) async {
  await _setPreference(_useDarkMode, enabled);
}

Future<void> setMaterial3Enabled(bool enabled) async {
  await _setPreference(_useMaterial3, enabled);
}
