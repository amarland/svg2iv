import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:svg2iv_common/extensions.dart';
import 'package:svg2iv_common/model/image_vector.dart';

import '../util/image_vector_painter.dart';

class Checkerboard extends StatefulWidget {
  const Checkerboard({
    Key? key,
    required this.size,
    required this.foregroundImageVector,
    this.squareColor,
  }) : super(key: key);

  final Size size;
  final Color? squareColor;
  final ImageVector foregroundImageVector;

  @override
  State<StatefulWidget> createState() => _CheckerboardState();
}

class _CheckerboardState extends State<Checkerboard> {
  ui.Image? _cachedImage;

  @override
  void initState() {
    _updateState();
    super.initState();
  }

  @override
  void didUpdateWidget(Checkerboard oldWidget) {
    _updateState(oldWidget);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CheckerboardPainter(
        widget.squareColor ??
            Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
      ),
      foregroundPainter: _cachedImage?.let(_ImagePainter.new),
    );
  }

  @override
  void dispose() {
    _cachedImage?.dispose();
    super.dispose();
  }

  // not awaited, but that's because it can't be from its call sites
  Future<void> _updateState([Checkerboard? oldWidget]) async {
    final size = widget.size;
    final foregroundImageVector = widget.foregroundImageVector;
    if (oldWidget == null ||
        _cachedImage == null ||
        foregroundImageVector != oldWidget.foregroundImageVector ||
        size != oldWidget.size) {
      final picture = foregroundImageVector.toPicture(size);
      final image =
          await picture.toImage(size.width.floor(), size.height.floor());
      setState(() {
        picture.dispose();
        _cachedImage?.dispose();
        _cachedImage = image;
      });
    }
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
  bool shouldRepaint(_CheckerboardPainter oldPainter) =>
      squareColor != oldPainter.squareColor;
}

class _ImagePainter extends CustomPainter {
  const _ImagePainter(this.picture);

  final ui.Image picture;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(picture, const ui.Offset(0.0, 0.0), ui.Paint());
  }

  @override
  bool shouldRepaint(_ImagePainter oldPainter) => picture != oldPainter.picture;
}
