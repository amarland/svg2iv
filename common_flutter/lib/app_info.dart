import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';
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
  required String applicationName,
  required String applicationVersion,
}) async {
  await showDialog<void>(
    context: context,
    builder: (context) {
      return CustomAboutDialog(
        applicationName: applicationName,
        applicationVersion: applicationVersion,
      );
    },
  );
}

class CustomAboutDialog extends StatefulWidget {
  const CustomAboutDialog({
    super.key,
    required this.applicationName,
    required this.applicationVersion,
  });

  final String applicationName;
  final String applicationVersion;

  @override
  State<CustomAboutDialog> createState() => _CustomAboutDialogState();
}

class _CustomAboutDialogState extends State<CustomAboutDialog> {
  static const repositoryUrl = 'https://github.com/amarland/svg2iv';

  final _gestureRecognizer = TapGestureRecognizer()
    ..onTap = () async => await launchUrlString(repositoryUrl);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return AboutDialog(
      applicationName: widget.applicationName,
      applicationVersion: widget.applicationVersion,
      applicationIcon: const VectorGraphic(
        loader: AssetBytesLoader(
          'res/icons/logo',
          packageName: 'svg2iv_common_flutter',
        ),
      ),
      applicationLegalese: '© 2023 Anthony Marland',
      children: [
        const SizedBox(height: 24.0),
        RichText(
          text: TextSpan(
            text: repositoryUrl,
            style: (themeData.textTheme.bodyMedium ?? const TextStyle())
                .copyWith(color: themeData.colorScheme.primary),
            recognizer: _gestureRecognizer,
            mouseCursor: SystemMouseCursors.click,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _gestureRecognizer.dispose();
    super.dispose();
  }
}
