import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.readOnly = false,
    this.error = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final bool readOnly;
  final bool error;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
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
}
