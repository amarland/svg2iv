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
    this.oddSquareColor,
    this.evenSquareColor,
  }) : super(key: key);

  final Size size;
  final Color? oddSquareColor;
  final Color? evenSquareColor;
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
    final themeData = Theme.of(context);
    final isInLightMode = themeData.brightness == Brightness.light;
    final onSurfaceColor = themeData.colorScheme.onSurface;
    return CustomPaint(
      painter: _CheckerboardPainter(
        oddSquareColor: widget.oddSquareColor ??
            onSurfaceColor.withOpacity(isInLightMode ? 0.38 : 0.54),
        evenSquareColor: widget.oddSquareColor ??
            onSurfaceColor.withOpacity(isInLightMode ? 0.08 : 0.16),
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
  const _CheckerboardPainter({
    required this.oddSquareColor,
    required this.evenSquareColor,
  }) : super();

  final Color oddSquareColor;
  final Color evenSquareColor;

  @override
  void paint(Canvas canvas, Size size) {
    const squareSize = 8.0;
    final actualWidth = size.width - size.width % squareSize;
    final actualHeight = size.height - size.height % squareSize;
    final offsetX = (size.width - actualWidth) / 2,
        offsetY = (size.height - actualHeight) / 2;
    double x = offsetX, y = offsetY;
    var odd = true;
    final paint = Paint()..isAntiAlias = false;
    while (y < actualHeight) {
      canvas.drawRect(
        Rect.fromLTWH(x, y, squareSize, squareSize),
        paint..color = odd ? oddSquareColor : evenSquareColor,
      );
      if (x < size.width - offsetX) {
        x += squareSize;
        odd = !odd;
      } else {
        x = (y + squareSize) % (squareSize);
        y += squareSize;
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerboardPainter oldPainter) =>
      oddSquareColor != oldPainter.oddSquareColor ||
      evenSquareColor != oldPainter.evenSquareColor;
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
