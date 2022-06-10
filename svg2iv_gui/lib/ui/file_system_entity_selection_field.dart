import 'package:flutter/material.dart';
import 'package:svg2iv_gui/ui/svg_icon.dart';

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
    final String iconAssetName;
    final TextSpan defaultLabelSpan;
    switch (widget.selectionMode) {
      case FileSystemEntitySelectionMode.sourceFiles:
        iconAssetName = 'assets/source_files.svg';
        defaultLabelSpan = 'Source files'.asMnemonic();
        break;
      case FileSystemEntitySelectionMode.destinationDirectory:
        iconAssetName = 'assets/destination_directory.svg';
        defaultLabelSpan = 'Destination directory'.asMnemonic();
        break;
    }
    final theme = Theme.of(context);
    final defaultInputBorder = theme.inputDecorationTheme.border;
    final inputBorder = defaultInputBorder?.copyWith(
      borderSide: defaultInputBorder.borderSide.copyWith(
        color: widget.isError
            ? theme.colorScheme.error
            // from 'input_decorator.dart',
            // `_InputDecoratorState._getDefaultBorderColor`
            : theme.colorScheme.onSurface.withOpacity(0.38),
      ),
    );
    final labelSpan = widget.isError
        ? TextSpan(
            children: [defaultLabelSpan],
            style: TextStyle(color: theme.colorScheme.error),
          )
        : defaultLabelSpan;
    return Row(
      children: [
        Flexible(
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
        OutlinedButton(
          onPressed: widget.onButtonPressed,
          child: SizedBox.fromSize(
            size: const Size(24.0, 52.0),
            child: const SvgIcon('assets/explore_files.svg'),
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
