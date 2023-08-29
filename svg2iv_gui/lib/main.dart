import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:svg2iv_common_flutter/app_info.dart';
import 'package:svg2iv_common_flutter/theme.dart';

import 'outer_world/preferences.dart';
import 'ui/app.dart';

const appName = 'svg2iv_gui';
const appVersion = '0.0.0-dev';

void main() async {
  addFontLicenses();
  final themeCubit = ThemeCubit(
    preferences: FilePreferences(),
    accentColorDelegate: _AccentColorDelegate(),
  );
  runApp(
    App(themeCubit: themeCubit),
  );
  doWhenWindowReady(() {
    appWindow
      ..alignment = Alignment.center
      ..show();
  });
  await themeCubit.loadTheme();
}

class _AccentColorDelegate implements AccentColorDelegate {
  @override
  Future<Color?> get accentColor => DynamicColorPlugin.getAccentColor();
}
