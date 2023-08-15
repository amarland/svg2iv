import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:svg2iv_common_flutter/app_info.dart';

import 'ui/app.dart';

const appName = 'svg2iv_gui';
const appVersion = '0.1.0';

void main() {
  addFontLicenses();
  runApp(const App());
  doWhenWindowReady(() {
    appWindow
      ..alignment = Alignment.center
      ..show();
  });
}
