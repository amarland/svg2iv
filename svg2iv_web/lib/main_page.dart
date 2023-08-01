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
  var showErrorMessages = false;

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
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(1),
                      child: Expanded(
                        child: _buildTextField(
                          controller: sourceTextController,
                          hintText: 'Paste your SVG/VectorDrawable markup here',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(3),
                      child: Expanded(
                        child: _buildTextField(
                          controller: imageVectorTextController,
                          hintText:
                              "Click 'Convert' to see the ImageVector code",
                          readOnly: true,
                          error: showErrorMessages,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              FocusTraversalOrder(
                order: const NumericFocusOrder(2),
                child: FilledButton(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool readOnly = false,
    bool error = false,
  }) {
    return Builder(builder: (context) {
      final themeData = Theme.of(context);
      final textTheme = themeData.textTheme;
      final errorColor = themeData.colorScheme.error;
      final textStyle = textTheme.bodySmall!.copyWith(
        color: error ? errorColor : null,
        fontFamily: 'JetBrainsMono',
        package: 'svg2iv_common_flutter',
      );
      return TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          errorText: error ? '\u200B' : null,
          errorStyle: const TextStyle(fontSize: 0.0),
          contentPadding: const EdgeInsets.all(12.0),
          prefixIcon: error
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    widthFactor: 1.0,
                    child: Icon(Icons.error_outline),
                  ),
                )
              : null,
          prefixIconColor: error ? errorColor : null,
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
    final bool showErrorMessages;
    final buffer = StringBuffer();
    if (imageVector != null) {
      writeFileContents(buffer, [imageVector]);
      showErrorMessages = false;
    } else if (errorMessages.isNotEmpty) {
      buffer.writeAll(errorMessages, '\n');
      showErrorMessages = true;
    } else {
      buffer.write('An unknown error has occurred.');
      showErrorMessages = true;
    }
    imageVectorTextController.text = buffer.toString();
    setState(() {
      this.showErrorMessages = showErrorMessages;
    });
  }

  @override
  void dispose() {
    super.dispose();
    sourceTextController.dispose();
    imageVectorTextController.dispose();
  }
}
