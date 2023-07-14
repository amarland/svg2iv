import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:svg2iv_common_flutter/preferences.dart';

import '../util/exception_handlers.dart';

class FilePreferences extends Preferences {
  @visibleForTesting
  FilePreferences.internal([this._file]) : super();

  factory FilePreferences() => _instance;

  static final FilePreferences _instance = FilePreferences.internal();

  File? _file;

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

  @override
  Future<Map<String, String>> loadPreferencesFromStorage() async {
    final preferences = HashMap<String, String>();
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
    return preferences;
  }

  @override
  Future<void> setPreference(String key, Object value) async {
    super.setPreference(key, value);
    _writePreferences();
  }

  Future<void> _writePreferences() async {
    final preferences = await getPreferences();
    return runIgnoringException<FileSystemException>(() async {
      final file = await _getFile();
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      final sink = file.openWrite();
      for (final entry in preferences.entries) {
        sink.writeln('${entry.key}=${entry.value}');
      }
      await sink.close();
    });
  }
}
