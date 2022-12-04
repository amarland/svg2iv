import 'package:flutter/material.dart';

class PreviewSelectionButton extends StatelessWidget {
  const PreviewSelectionButton({
    super.key,
    required this.onPressed,
    required this.iconData,
  });

  final VoidCallback? onPressed;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.square(56.0),
        shape: const CircleBorder(),
      ),
      child: Icon(iconData),
    );
  }
}
