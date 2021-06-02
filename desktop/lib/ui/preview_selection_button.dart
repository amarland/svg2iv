import 'package:flutter/material.dart';

class PreviewSelectionButton extends StatelessWidget {
  const PreviewSelectionButton({
    Key? key,
    required this.icon,
    this.isEnabled = true,
  }) : super(key: key);

  final IconData icon;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled
          ? () {
              /* TODO */
            }
          : null,
      child: Icon(icon),
    );
  }
}
