import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ui/app.dart';

void main() {
  LicenseRegistry.addLicense(
    () => Stream.fromFutures(
      ['JetBrains Mono', 'Noto Sans'].map(
        (fontName) async => LicenseEntryWithLineBreaks(
          [fontName],
          await rootBundle.loadString(
            'res/fonts/${fontName.replaceAll(' ', '')}/OFL.txt',
          ),
        ),
      ),
    ),
  );
  runApp(const App());
  doWhenWindowReady(() {
    appWindow
      ..alignment = Alignment.center
      ..show();
  });
}
