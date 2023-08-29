import 'package:flutter/material.dart';
import 'package:svg2iv_common_flutter/app_info.dart';
import 'package:svg2iv_common_flutter/theme.dart';
import 'package:svg2iv_web/preferences.dart';

import 'ui/app.dart';

const appName = 'svg2iv';
const appVersion = '0.1.0';

void main() async {
  addFontLicenses();
  final themeCubit = ThemeCubit(preferences: BrowserPreferences());
  runApp(
    App(themeCubit: themeCubit),
  );
  await themeCubit.loadTheme();
}
