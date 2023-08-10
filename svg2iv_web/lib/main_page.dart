import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:svg2iv_common/parser.dart';
import 'package:svg2iv_common/writer.dart';
import 'package:svg2iv_common_flutter/app_info.dart' as app_info;
import 'package:svg2iv_common_flutter/image_vector_preview.dart';
import 'package:svg2iv_common_flutter/theme.dart';
import 'package:svg2iv_common_flutter/widgets.dart';

import 'main.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

enum _ImageVectorViewMode {
  code,
  preview;
}

class _MainPageState extends State<MainPage> {
  final _sourceTextController = TextEditingController();
  final _imageVectorTextController = TextEditingController();
  late DropzoneViewController _dropzoneViewController;
  ImageVector? _imageVector;
  var _isSegmentedButtonVisible = false;
  var _imageVectorViewMode = _ImageVectorViewMode.code;
  var _areErrorsVisible = false;
  var _isConvertButtonEnabled = false;

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
                    _buildLeftTextField(),
                    const SizedBox(width: 16.0),
                    _buildRightTextField(),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              FocusTraversalOrder(
                order: const NumericFocusOrder(2),
                child: FilledButton(
                  onPressed:
                      _isConvertButtonEnabled ? _onConvertButtonClicked : null,
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

  Widget _buildLeftTextField() {
    return Expanded(
      child: Stack(
        children: [
          DropzoneView(
            operation: DragOperation.copy,
            mime: const [
              'application/xml',
              'text/xml',
              'image/svg+xml',
            ],
            onCreated: (controller) => _dropzoneViewController = controller,
            onDrop: _onSourceFileDropped,
          ),
          FocusTraversalOrder(
            order: const NumericFocusOrder(1),
            child: _buildTextField(
              controller: _sourceTextController,
              hintText: 'Paste your SVG/VectorDrawable markup here',
              onChanged: (text) {
                final enabled = text.isNotEmpty;
                if (enabled != _isConvertButtonEnabled) {
                  setState(() => _isConvertButtonEnabled = enabled);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightTextField() {
    final Widget imageVectorAsWidget = switch (_imageVectorViewMode) {
      _ImageVectorViewMode.code => FocusTraversalOrder(
          order: const NumericFocusOrder(3),
          child: _buildTextField(
            controller: _imageVectorTextController,
            hintText: "Click 'Convert' to see the ImageVector code",
            readOnly: true,
            error: _areErrorsVisible,
          ),
        ),
      _ImageVectorViewMode.preview => AspectRatio(
          aspectRatio: 1.0,
          child: LayoutBuilder(
            builder: (_, constraints) {
              return Checkerboard(
                size: constraints.biggest,
                imageVector: _imageVector,
              );
            },
          ),
        )
    };
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          imageVectorAsWidget,
          if (_isSegmentedButtonVisible)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FocusTraversalOrder(
                  order: const NumericFocusOrder(4),
                  child: SegmentedButton(
                    segments: const [
                      ButtonSegment(
                        value: _ImageVectorViewMode.code,
                        icon: Icon(Icons.code_outlined),
                        label: Text('Code'),
                      ),
                      ButtonSegment(
                        value: _ImageVectorViewMode.preview,
                        icon: Icon(Icons.image_outlined),
                        label: Text('Preview'),
                      ),
                    ],
                    selected: {_imageVectorViewMode},
                    onSelectionChanged: (selection) {
                      setState(() => _imageVectorViewMode = selection.single);
                    },
                    showSelectedIcon: false,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool readOnly = false,
    bool error = false,
    ValueChanged<String>? onChanged,
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
                    child: Icon(Icons.error_outline_outlined),
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
        onChanged: onChanged,
      );
    });
  }

  void _onConvertButtonClicked() {
    final (imageVector, errorMessages) = parseXmlString(
      _sourceTextController.text,
    );
    _imageVector = imageVector;
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
    _imageVectorTextController.text = buffer.toString();
    setState(() {
      _isSegmentedButtonVisible = !showErrorMessages;
      _areErrorsVisible = showErrorMessages;
      if (showErrorMessages) _imageVectorViewMode = _ImageVectorViewMode.code;
    });
  }

  void _onSourceFileDropped(dynamic file) async {
    // TODO: show feedback
    _sourceTextController.text = await utf8.decodeStream(
      _dropzoneViewController.getFileStream(file),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _sourceTextController.dispose();
    _imageVectorTextController.dispose();
  }
}
