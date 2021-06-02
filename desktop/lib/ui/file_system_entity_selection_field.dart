import 'package:desktop/ui/file_system_entity_selection_mode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      case FileSystemEntitySelectionMode.source_files:
        icon = Icons.upload_file_outlined;
        // labelSpans = 'Source files'.asMnemonic();
        label = 'Source files';
        break;
      case FileSystemEntitySelectionMode.destination_directory:
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
              border: OutlineInputBorder(),
            ),
            readOnly: true,
          ),
        ),
        SizedBox(width: 8.0),
        SizedBox.fromSize(
          size: Size.square(50.0),
          child: OutlinedButton(
            onPressed: isButtonEnabled
                ? () {
                    /* TODO */
                  }
                : null,
            child: Icon(Icons.folder_outlined),
          ),
        ),
      ],
    );
  }
}
