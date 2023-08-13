import 'package:flutter/material.dart';
import 'package:svg2iv_common/parser.dart';
import 'package:svg2iv_common/writer.dart';
import 'package:svg2iv_common_flutter/image_vector_preview.dart';

import 'custom_text_field.dart';

class ImageVectorViewer extends StatefulWidget {
  const ImageVectorViewer({
    super.key,
    required this.focusOrder,
    this.focusNode,
    this.parseResult,
  });

  final double focusOrder;
  final FocusNode? focusNode;
  final ParseResult? parseResult;

  @override
  State<StatefulWidget> createState() => _ImageVectorViewerState();
}

enum _ImageVectorViewMode { code, preview }

class _ImageVectorViewerState extends State<ImageVectorViewer> {
  final _textController = TextEditingController();
  ImageVector? _imageVector;
  var _isSegmentedButtonVisible = false;
  var _imageVectorViewMode = _ImageVectorViewMode.code;
  var _areErrorsVisible = false;

  @override
  void didUpdateWidget(ImageVectorViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final parseResult = widget.parseResult;
    if (parseResult != null) {
      final (imageVector, errorMessages) = parseResult;
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
      _textController.text = buffer.toString();
      setState(() {
        _isSegmentedButtonVisible = !showErrorMessages;
        _areErrorsVisible = showErrorMessages;
        if (showErrorMessages) _imageVectorViewMode = _ImageVectorViewMode.code;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget imageVectorAsWidget = switch (_imageVectorViewMode) {
      _ImageVectorViewMode.code => FocusTraversalOrder(
          order: NumericFocusOrder(widget.focusOrder),
          child: CustomTextField(
            controller: _textController,
            hintText: "Click 'Convert' to see the ImageVector code.",
            focusNode: widget.focusNode,
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
    return Stack(
      alignment: Alignment.center,
      children: [
        imageVectorAsWidget,
        if (_isSegmentedButtonVisible)
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FocusTraversalOrder(
                order: NumericFocusOrder(widget.focusOrder + 0.1),
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
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
