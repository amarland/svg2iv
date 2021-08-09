import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:svg2iv_gui/ui/file_system_entity_selection_mode.dart';

class FileSystemEntitySelectionField extends StatelessWidget {
  const FileSystemEntitySelectionField({
    Key? key,
    required this.selectionMode,
    this.value = '',
    this.isError = false,
    this.isButtonEnabled = true,
  }) : super(key: key);

  final FileSystemEntitySelectionMode selectionMode;
  final String value;
  final bool isError;
  final bool isButtonEnabled;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    // final List<TextSpan> labelSpans;
    final String label;
    switch (selectionMode) {
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
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon),
              border: const OutlineInputBorder(),
            ),
            readOnly: true,
          ),
        ),
        const SizedBox(width: 8.0),
        SizedBox.fromSize(
          size: const Size.square(50.0),
          child: OutlinedButton(
            onPressed: isButtonEnabled
                ? () {
                    /* TODO */
                  }
                : null,
            child: const Icon(Icons.folder_outlined),
          ),
        ),
      ],
    );
  }
}
