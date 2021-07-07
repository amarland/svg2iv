import 'package:flutter/material.dart';

class Checkerboard extends StatelessWidget {
  const Checkerboard({Key? key, this.squareColor, this.child})
      : super(key: key);

  final Color? squareColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CheckerboardPainter(
        squareColor ??
            Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
      ),
      child: child,
    );
  }
}

class _CheckerboardPainter extends CustomPainter {
  const _CheckerboardPainter(this.squareColor) : super();

  final Color squareColor;

  @override
  void paint(Canvas canvas, Size size) {
    const squareSize = 8.0;
    final actualWidth = size.width - size.width % squareSize;
    final actualHeight = size.height - size.height % squareSize;
    final offsetX = (size.width - actualWidth) / 2,
        offsetY = (size.height - actualHeight) / 2;
    double x = offsetX, y = offsetY;
    final paint = Paint()..color = squareColor;
    while (y < actualHeight) {
      canvas.drawRect(
        Rect.fromLTWH(x, y, squareSize, squareSize),
        paint,
      );
      if (x < actualWidth - squareSize * 2) {
        x += squareSize * 2;
      } else {
        x = (y + squareSize) % (squareSize * 2);
      }
      if (x <= squareSize + offsetX) {
        y += squareSize;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
