import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

const _isDarkModeEnabled = "is_dark_mode_enabled";

Future<String> get _filePath async {
  return path.join(
    (await path_provider.getApplicationSupportDirectory()).path,
    'svg2iv.ini',
  );
}

Future<bool> isDarkModeEnabled() async {
  final file = File(await _filePath);
  if (await file.exists()) {
    final line = (await file.readAsLines())[0];
    if (line.startsWith(_isDarkModeEnabled) &&
        line.substring(_isDarkModeEnabled.length + 1).toLowerCase() == 'true') {
      return true;
    }
  }
  return false;
}

Future<void> setDarkModeEnabled(bool enabled) async =>
    await File(await _filePath)
        .writeAsString('$_isDarkModeEnabled=$enabled', flush: true);
