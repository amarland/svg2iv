import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg2iv_common/parser.dart';
import 'package:svg2iv_common_flutter/app_info.dart' as app_info;
import 'package:svg2iv_common_flutter/theme.dart';
import 'package:svg2iv_common_flutter/widgets.dart';

import 'image_vector_viewer.dart';
import 'main.dart';
import 'source_text_field.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _sourceTextController = TextEditingController();
  ParseResult? _parseResult;
  var _isConvertButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _sourceTextController.addListener(() {
      final isTextNotEmpty = _sourceTextController.text.isNotEmpty;
      if (isTextNotEmpty != _isConvertButtonEnabled) {
        setState(() => _isConvertButtonEnabled = isTextNotEmpty);
      }
    });
  }

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
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: SourceTextField(
                        textController: _sourceTextController,
                        focusOrder: 1,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: ImageVectorViewer(
                        focusOrder: 3,
                        parseResult: _parseResult,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              FocusTraversalOrder(
                order: const NumericFocusOrder(2),
                child: FilledButton(
                  onPressed: _isConvertButtonEnabled
                      ? () {
                          setState(() {
                            // TODO: make this async
                            _parseResult = parseXmlString(
                              _sourceTextController.text,
                            );
                          });
                        }
                      : null,
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

  @override
  void dispose() {
    super.dispose();
    _sourceTextController.dispose();
  }
}
