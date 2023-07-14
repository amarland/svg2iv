import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg2iv_common/parser.dart';
import 'package:svg2iv_common/writer.dart';
import 'package:svg2iv_common_flutter/app_info.dart' as app_info;
import 'package:svg2iv_common_flutter/theme.dart';
import 'package:svg2iv_common_flutter/widgets.dart';

import 'main.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final sourceTextController = TextEditingController();
  final imageVectorTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MainPageScaffold(
      onToggleThemeButtonPressed: () {
        BlocProvider.of<ThemeCubit>(context).toggleTheme();
      },
      onAboutButtonPressed: () {
        app_info.showAboutDialog(context, name: appName, version: appVersion);
      },
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: sourceTextController,
                      hintText: 'Paste your SVG/VectorDrawable markup here',
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _buildTextField(
                      controller: imageVectorTextController,
                      hintText: "Click 'Convert' to see the ImageVector code",
                      readOnly: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            FilledButton(
              onPressed: _onConvertButtonClicked,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgIcon('res/icons/convert_vector'),
                  SizedBox(width: 8.0),
                  Text('Convert'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool readOnly = false,
  }) {
    return Builder(builder: (context) {
      final textTheme = Theme.of(context).textTheme;
      final textStyle = textTheme.bodySmall!.copyWith(
        fontFamily: 'JetBrainsMono',
        package: 'svg2iv_common_flutter',
      );
      return TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.all(12.0),
        ),
        style: textStyle,
        textAlignVertical: TextAlignVertical.top,
        readOnly: readOnly,
        autocorrect: false,
        enableSuggestions: false,
        maxLines: null,
        expands: true,
      );
    });
  }

  void _onConvertButtonClicked() {
    final (imageVector, errorMessages) = parseXmlString(
      sourceTextController.text,
    );
    if (imageVector != null) {
      final buffer = StringBuffer();
      writeFileContents(buffer, [imageVector]);
      imageVectorTextController.text = buffer.toString();
    }
    // TODO: show errors
  }

  @override
  void dispose() {
    super.dispose();
    sourceTextController.dispose();
    imageVectorTextController.dispose();
  }
}
