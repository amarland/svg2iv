import 'package:flutter/material.dart';
import 'package:svg2iv_common_flutter/app_info.dart';

import 'ui/app.dart';

const appName = 'svg2iv';
const appVersion = '0.1.0';

void main() {
  addFontLicenses();
  runApp(const App());
}
