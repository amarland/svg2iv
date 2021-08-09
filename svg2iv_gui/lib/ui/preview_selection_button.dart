import 'package:flutter/material.dart';

class PreviewSelectionButton extends StatelessWidget {
  const PreviewSelectionButton({
    Key? key,
    required this.onPressed,
    required this.iconData,
  }) : super(key: key);

  final VoidCallback onPressed;
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
