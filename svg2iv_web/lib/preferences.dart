// ignore: avoid_web_libraries_in_flutter
import 'dart:html' show window;

import 'package:flutter/material.dart';
import 'package:svg2iv_common_flutter/preferences.dart';

class BrowserPreferences extends Preferences {
  @visibleForTesting
  BrowserPreferences.internal([
    Map<String, String>? preferences,
  ]) : super(preferences);

  factory BrowserPreferences() => _instance;

  static final BrowserPreferences _instance = BrowserPreferences.internal();

  @override
  Future<Map<String, String>> loadPreferencesFromStorage() async =>
      window.localStorage;
}
