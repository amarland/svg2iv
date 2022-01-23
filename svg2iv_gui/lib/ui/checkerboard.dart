import 'dart:ui';

import 'package:flutter/material.dart';

typedef PictureBuilder = Picture Function(Size size);

class Checkerboard extends StatelessWidget {
  const Checkerboard({
    Key? key,
    this.squareColor,
    this.foregroundPictureBuilder,
  }) : super(key: key);

  final Color? squareColor;
  final PictureBuilder? foregroundPictureBuilder;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CheckerboardPainter(
        squareColor ??
            Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
      ),
      foregroundPainter: foregroundPictureBuilder != null
          ? _PicturePainter(foregroundPictureBuilder!)
          : null,
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
    while (y < actualHeight) {
      canvas.drawRect(
        Rect.fromLTWH(x, y, squareSize, squareSize),
        Paint()..color = squareColor,
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

class _PicturePainter extends CustomPainter {
  const _PicturePainter(this.pictureBuilder);

  final PictureBuilder pictureBuilder;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPicture(pictureBuilder(size));
  }

  @override
  bool shouldRepaint(_PicturePainter oldPainter) => false;
}
