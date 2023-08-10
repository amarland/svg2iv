import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

import 'custom_text_field.dart';

class SourceTextField extends StatefulWidget {
  const SourceTextField({
    super.key,
    required this.textController,
    required this.focusOrder,
  });

  final TextEditingController textController;
  final double focusOrder;

  @override
  State<StatefulWidget> createState() => _SourceTextFieldState();
}

class _SourceTextFieldState extends State<SourceTextField> {
  late DropzoneViewController _dropzoneViewController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DropzoneView(
          operation: DragOperation.copy,
          mime: const [
            'application/xml',
            'text/xml',
            'image/svg+xml',
          ],
          onCreated: (controller) => _dropzoneViewController = controller,
          onDrop: (file) async {
            // TODO: show feedback
            widget.textController.text = await utf8.decodeStream(
              _dropzoneViewController.getFileStream(file),
            );
          },
        ),
        FocusTraversalOrder(
          order: NumericFocusOrder(widget.focusOrder),
          child: CustomTextField(
            controller: widget.textController,
            hintText: 'Paste/drop your SVG/VectorDrawable markup/file here',
          ),
        ),
      ],
    );
  }
}
