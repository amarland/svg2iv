import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

import '../ui/app.dart';

void main() async {
  runApp(const App());
  doWhenWindowReady(() {
    appWindow
      ..alignment = Alignment.center
      ..show();
  });
}
