import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:svg2iv_common/extensions.dart';
import 'package:svg2iv_common/parser.dart';
import 'package:svg2iv_common_flutter/widgets.dart';

import 'custom_text_field.dart';

class SourceTextField extends StatefulWidget {
  const SourceTextField({
    super.key,
    required this.focusOrder,
    required this.onSourceParsed,
    this.readOnly = false,
  });

  final double focusOrder;
  final void Function(ParseResult) onSourceParsed;
  final bool readOnly;

  @override
  State<StatefulWidget> createState() => _SourceTextFieldState();
}

enum _FabAction { selectFile, convertSource }

sealed class _DropzoneEvent {
  const _DropzoneEvent();
}

class _DropEvent extends _DropzoneEvent {
  const _DropEvent(this.file);

  final dynamic file;
}

class _DropInvalidEvent extends _DropzoneEvent {
  const _DropInvalidEvent();
}

class _DropMultipleEvent extends _DropzoneEvent {
  const _DropMultipleEvent();
}

class _SourceTextFieldState extends State<SourceTextField> {
  final _textController = TextEditingController();
  late DropzoneViewController _dropzoneController;
  var _areInteractionsEnabled = true;
  _FabAction _fabAction = _FabAction.selectFile;
  final _dropzoneEventsController = StreamController<_DropzoneEvent>();
  String? _droppedFileName;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      final isTextFieldEmpty = _textController.text.isEmpty;
      if (!isTextFieldEmpty && _fabAction == _FabAction.selectFile) {
        setState(() => _fabAction = _FabAction.convertSource);
      } else if (isTextFieldEmpty && _fabAction == _FabAction.convertSource) {
        setState(() => _fabAction = _FabAction.selectFile);
      }
    });
    _dropzoneEventsController.stream
        .debounceBuffer(const Duration(milliseconds: 100))
        .listen((events) {
      T? firstEventOfType<T extends _DropzoneEvent>() {
        final event = events.firstWhereOrNull((e) => e is T);
        return event != null ? event as T : null;
      }

      final dropMultipleEvent = firstEventOfType<_DropMultipleEvent>();
      if (dropMultipleEvent != null || events.length > 1) {
        _showSnackBar(context, 'Only one file at a time for now, sorry!');
      } else if (firstEventOfType<_DropInvalidEvent>() != null) {
        _showSnackBar(context, 'The type of the file you dropped is invalid.');
      }
      final droppedFile = firstEventOfType<_DropEvent>()?.file;
      if (droppedFile != null) _onFileSelected(droppedFile);
    });
  }

  @override
  Widget build(BuildContext context) {
    const mimeTypes = [
      'application/xml',
      'text/xml',
      'image/svg+xml',
    ];
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        DropzoneView(
          operation: DragOperation.copy,
          mime: mimeTypes,
          onCreated: (controller) => _dropzoneController = controller,
          onDrop: (file) => _dropzoneEventsController.add(_DropEvent(file)),
          onDropInvalid: (_) {
            _dropzoneEventsController.add(const _DropInvalidEvent());
          },
          onDropMultiple: (_) {
            _dropzoneEventsController.add(const _DropMultipleEvent());
          },
        ),
        FocusTraversalOrder(
          order: NumericFocusOrder(widget.focusOrder),
          child: CustomTextField(
            controller: _textController,
            hintText: '''
Paste your SVG/VectorDrawable markup here.

If you prefer, you can also drag and drop an SVG/VectorDrawable file into this area.

Alternatively, you can open a file by clicking the button below.''',
            readOnly: widget.readOnly,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: FocusTraversalOrder(
            order: NumericFocusOrder(widget.focusOrder + 0.1),
            child: FloatingActionButton.extended(
              onPressed: _areInteractionsEnabled
                  ? switch (_fabAction) {
                      _FabAction.selectFile => () async {
                          final files = await _dropzoneController.pickFiles(
                            mime: mimeTypes,
                          );
                          final file = files.singleOrNull;
                          if (file != null) _onFileSelected(file);
                        },
                      _FabAction.convertSource => _onConvertButtonClicked,
                    }
                  : null,
              icon: switch (_fabAction) {
                _FabAction.selectFile => const Icon(Icons.file_open_outlined),
                _FabAction.convertSource => const SvgIcon(
                    'res/icons/convert_vector',
                    packageName: 'svg2iv_common_flutter',
                  ),
              },
              label: switch (_fabAction) {
                _FabAction.selectFile => const Text('Select file'),
                _FabAction.convertSource => const Text('Convert'),
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  void _onFileSelected(dynamic file) async {
    _droppedFileName = await _dropzoneController.getFilename(file);
    setState(() => _areInteractionsEnabled = false);
    _textController.text = await utf8.decodeStream(
      _dropzoneController.getFileStream(file),
    );
    setState(() => _areInteractionsEnabled = true);
  }

  void _onConvertButtonClicked() async {
    setState(() => _areInteractionsEnabled = false);
    final parseResult = await compute(
      _parseSource,
      (text: _textController.text, fileName: _droppedFileName),
    );
    setState(() => _areInteractionsEnabled = true);
    widget.onSourceParsed(parseResult);
  }

  ParseResult _parseSource(({String text, String? fileName}) source) =>
      parseXmlString(source.text, sourcePath: source.fileName);

  @override
  void dispose() {
    _textController.dispose();
    _dropzoneEventsController.close();
    super.dispose();
  }
}
