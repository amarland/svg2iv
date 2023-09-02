import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg2iv_common/parser.dart';
import 'package:svg2iv_common_flutter/app_info.dart' as app_info;
import 'package:svg2iv_common_flutter/theme.dart';
import 'package:svg2iv_common_flutter/widgets.dart';

import '../main.dart';
import 'image_vector_viewer.dart';
import 'source_text_field.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _imageVectorViewerFocusNode = FocusNode();
  ParseResult? _parseResult;

  @override
  Widget build(BuildContext context) {
    return MainPageScaffold(
      onToggleThemeButtonPressed: () async {
        await BlocProvider.of<ThemeCubit>(context).toggleTheme();
      },
      onAboutButtonPressed: () async {
        await app_info.showAboutDialog(
          context,
          applicationName: appName,
          applicationVersion: appVersion,
        );
      },
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Row(
            children: [
              Expanded(
                child: SourceTextField(
                  focusOrder: 1,
                  onSourceParsed: (result) {
                    setState(() => _parseResult = result);
                    _imageVectorViewerFocusNode.requestFocus();
                  },
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: ImageVectorViewer(
                  focusOrder: 2,
                  parseResult: _parseResult,
                  focusNode: _imageVectorViewerFocusNode,
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
    _imageVectorViewerFocusNode.dispose();
    super.dispose();
  }
}
