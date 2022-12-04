import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:svg2iv_common/extensions.dart';

import '../util/exception_handlers.dart';

const _isDarkModeEnabled = "is_dark_mode_enabled";

Future<String> get _filePath async {
  return path.join(
    (await path_provider.getApplicationSupportDirectory()).path,
    'svg2iv.ini',
  );
}

Future<ThemeMode> getThemeMode() async {
  final file = File(await _filePath);
  var themeMode = ThemeMode.system;
  await runIgnoringException<FileSystemException>(() async {
    if (await file.exists()) {
      final line = (await file.readAsLines())
          .firstOrNull
          ?.takeIf((line) => line.startsWith(_isDarkModeEnabled));
      if (line != null) {
        switch (line.substring(_isDarkModeEnabled.length + 1).toLowerCase()) {
          case 'true':
            themeMode = ThemeMode.dark;
            break;
          case 'false':
            themeMode = ThemeMode.light;
            break;
        }
      }
    }
  });
  return themeMode;
}

Future<void> setDarkModeEnabled(bool enabled) async {
  return runIgnoringException<FileSystemException>(() async {
    await File(await _filePath).writeAsString(
      '$_isDarkModeEnabled=$enabled',
      flush: true,
    );
  });
}
