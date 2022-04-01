import 'package:flutter/material.dart';

import '../ui/file_system_entity_selection_mode.dart';
import '../util/mnemonic_text_spans.dart';

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
    final TextSpan labelSpan;
    switch (widget.selectionMode) {
      case FileSystemEntitySelectionMode.sourceFiles:
        icon = Icons.upload_file_outlined;
        labelSpan = 'Source files'.asMnemonic();
        break;
      case FileSystemEntitySelectionMode.destinationDirectory:
        icon = Icons.snippet_folder_outlined;
        labelSpan = 'Destination directory'.asMnemonic();
        break;
    }
    return Row(
      children: [
        Flexible(
          child: TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              label: widget.isError
                  ? null
                  : Text.rich(labelSpan, overflow: TextOverflow.ellipsis),
              prefixIcon: Icon(icon),
              border: const OutlineInputBorder(),
              errorText: widget.isError ? labelSpan.text : null,
            ),
            readOnly: true,
          ),
        ),
        const SizedBox(width: 8.0),
        OutlinedButton(
          onPressed: widget.onButtonPressed,
          child: SizedBox.fromSize(
            size: const Size(24.0, 52.0),
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
