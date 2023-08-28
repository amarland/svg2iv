import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_graphics/vector_graphics.dart';

const _fonts = [
  ('JetBrains Mono', 'JetBrainsMono'),
  ('Noto Sans', 'NotoSans'),
];

void addFontLicenses() {
  LicenseRegistry.addLicense(
    () {
      return Stream.fromFutures(
        _fonts.map(
          (pair) async {
            final (fontName, directoryName) = pair;
            return LicenseEntryWithLineBreaks(
              [fontName],
              await rootBundle.loadString(
                'packages/svg2iv_common_flutter/'
                'res/fonts/$directoryName/OFL.txt',
              ),
            );
          },
        ),
      );
    },
  );
}

Future<void> showAboutDialog(
  BuildContext context, {
  required String name,
  required String version,
}) async {
  await showDialog<void>(
    context: context,
    builder: (context) {
      return AboutDialog(
        applicationName: name,
        applicationVersion: version,
        applicationIcon: const VectorGraphic(
          loader: AssetBytesLoader(
            'res/icons/logo',
            packageName: 'svg2iv_common_flutter',
          ),
        ),
        applicationLegalese: '© 2023 Anthony Marland',
      );
    },
  );
}
