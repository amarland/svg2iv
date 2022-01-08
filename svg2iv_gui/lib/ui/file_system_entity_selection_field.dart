import 'package:flutter/material.dart';
import 'package:svg2iv_gui/ui/file_system_entity_selection_mode.dart';

class FileSystemEntitySelectionField extends StatefulWidget {
  const FileSystemEntitySelectionField({
    Key? key,
    required this.onButtonPressed,
    required this.selectionMode,
    this.value = '',
    this.isError = false,
  }) : super(key: key);

  final VoidCallback? onButtonPressed;
  final FileSystemEntitySelectionMode selectionMode;
  final String value;
  final bool isError;

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<FileSystemEntitySelectionField> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void didUpdateWidget(FileSystemEntitySelectionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _textEditingController.text = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    // final List<TextSpan> labelSpans;
    final String label;
    switch (widget.selectionMode) {
      case FileSystemEntitySelectionMode.sourceFiles:
        icon = Icons.upload_file_outlined;
        // labelSpans = 'Source files'.asMnemonic();
        label = 'Source files';
        break;
      case FileSystemEntitySelectionMode.destinationDirectory:
        icon = Icons.snippet_folder_outlined;
        // labelSpans = 'Destination directory'.asMnemonic();
        label = 'Destination directory';
        break;
    }
    return Row(
      children: [
        Flexible(
          child: TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              labelText: widget.isError ? null : label,
              prefixIcon: Icon(icon),
              border: const OutlineInputBorder(),
              errorText: widget.isError ? label : null,
            ),
            readOnly: true,
          ),
        ),
        const SizedBox(width: 8.0),
        SizedBox.fromSize(
          size: const Size.square(50.0),
          child: OutlinedButton(
            onPressed: widget.onButtonPressed,
            child: const Icon(Icons.folder_outlined),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
