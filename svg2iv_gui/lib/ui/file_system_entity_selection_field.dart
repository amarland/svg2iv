import 'package:flutter/material.dart';
import 'package:svg2iv_gui/ui/svg_icon.dart';

import '../ui/file_system_entity_selection_mode.dart';
import '../util/mnemonic_text_spans.dart';

class FileSystemEntitySelectionField extends StatefulWidget {
  const FileSystemEntitySelectionField({
    super.key,
    required this.onButtonPressed,
    required this.selectionMode,
    this.value = '',
    this.isError = false,
  });

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
    final String iconAssetName;
    final TextSpan defaultLabelSpan;
    switch (widget.selectionMode) {
      case FileSystemEntitySelectionMode.sourceFiles:
        iconAssetName = 'res/source_files.svg';
        defaultLabelSpan = 'Source files'.asMnemonic();
        break;
      case FileSystemEntitySelectionMode.destinationDirectory:
        iconAssetName = 'res/destination_directory.svg';
        defaultLabelSpan = 'Destination directory'.asMnemonic();
        break;
    }
    final theme = Theme.of(context);
    final inputDecorationTheme = theme.inputDecorationTheme;
    final inputBorder = widget.isError
        ? inputDecorationTheme.errorBorder
        : inputDecorationTheme.enabledBorder;
    final labelSpan = widget.isError
        ? TextSpan(
            children: [defaultLabelSpan],
            style: TextStyle(color: theme.colorScheme.error),
          )
        : defaultLabelSpan;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              label: Text.rich(labelSpan, overflow: TextOverflow.ellipsis),
              prefixIcon: SvgIcon(iconAssetName),
              enabledBorder: inputBorder,
            ),
            readOnly: true,
          ),
        ),
        const SizedBox(width: 8.0),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 56.0, minHeight: 56.0),
          child: OutlinedButton(
            onPressed: widget.onButtonPressed,
            style: OutlinedButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              side: theme.inputDecorationTheme.enabledBorder?.borderSide,
            ),
            child: const SvgIcon('res/explore_files.svg'),
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
