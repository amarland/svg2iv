import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:svg2iv_common/extensions.dart';
import 'package:svg2iv_common/models.dart';

import '../util/image_vector_painter.dart';

class Checkerboard extends StatefulWidget {
  const Checkerboard({
    super.key,
    required this.size,
    required this.imageVector,
    this.oddSquareColor,
    this.evenSquareColor,
  });

  final Size size;
  final Color? oddSquareColor;
  final Color? evenSquareColor;
  final ImageVector? imageVector;

  @override
  State<StatefulWidget> createState() => _CheckerboardState();
}

class _CheckerboardState extends State<Checkerboard> {
  ui.Image? _cachedImage;
  late Rect _rect;
  late double _squareSize;

  @override
  void initState() {
    super.initState();
    _updateState();
  }

  @override
  void didUpdateWidget(Checkerboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateState(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colors = themeData.colorScheme;
    if (widget.imageVector == null) {
      return const SizedBox(
        width: 48.0,
        height: 48.0,
        child: CircularProgressIndicator(),
      );
    } else {
      return CustomPaint(
        painter: _CheckerboardPainter(
          rect: _rect,
          squareSize: _squareSize,
          oddSquareColor:
              widget.oddSquareColor ?? colors.onInverseSurface.withOpacity(0.5),
          evenSquareColor:
              widget.oddSquareColor ?? colors.onSurfaceVariant.withOpacity(0.5),
        ),
        foregroundPainter: _cachedImage?.let(_ImagePainter.new),
      );
    }
  }

  void _updateState([Checkerboard? oldWidget]) {
    final imageVector = widget.imageVector;
    if (imageVector != null) {
      final size = widget.size;
      if (oldWidget == null ||
          imageVector != oldWidget.imageVector ||
          size != oldWidget.size) {
        final shortestSide = size.shortestSide;
        final squareSize = shortestSide / 16 - (shortestSide / 16) % 4;
        final actualWidth = size.width - size.width % squareSize;
        final actualHeight = size.height - size.height % squareSize;
        final offsetX = (size.width - actualWidth) / 2,
            offsetY = (size.height - actualHeight) / 2;
        final aspectRatio = imageVector.width / imageVector.height;
        final int imageVectorWidth, imageVectorHeight;
        if (aspectRatio.isNegative) {
          imageVectorWidth = (actualWidth / aspectRatio).floor();
          imageVectorHeight = actualHeight.floor();
        } else {
          imageVectorWidth = actualWidth.floor();
          imageVectorHeight = (actualHeight / aspectRatio).floor();
        }
        final picture = imageVector.toPicture(
          imageVectorWidth,
          imageVectorHeight,
        );
        final image = picture.toImageSync(
          imageVectorWidth,
          imageVectorHeight,
        );
        picture.dispose();
        _cachedImage?.dispose();
        _cachedImage = image;
        _rect = Rect.fromLTWH(offsetX, offsetY, actualWidth, actualHeight);
        _squareSize = squareSize;
      }
    }
  }
}

class _CheckerboardPainter extends CustomPainter {
  const _CheckerboardPainter({
    required this.rect,
    required this.squareSize,
    required this.oddSquareColor,
    required this.evenSquareColor,
  }) : super();

  final Rect rect;
  final double squareSize;
  final Color oddSquareColor;
  final Color evenSquareColor;

  @override
  void paint(Canvas canvas, Size size) {
    double x = rect.left, y = rect.top;
    var odd = true;
    final paint = Paint()..isAntiAlias = false;
    final rowCount = rect.height ~/ squareSize - 1;
    final columnCount = rect.width ~/ squareSize - 1;
    for (int row = 0; row <= rowCount; row++) {
      for (int column = 0; column <= columnCount; column++) {
        canvas.drawRect(
          Rect.fromLTWH(x, y, squareSize, squareSize),
          paint..color = odd ? oddSquareColor : evenSquareColor,
        );
        x += squareSize;
        odd = !odd;
      }
      x = rect.left;
      y += squareSize;
      if (columnCount % 2 == 1) odd = !odd;
    }
  }

  @override
  bool shouldRepaint(_CheckerboardPainter oldPainter) =>
      rect != oldPainter.rect ||
      squareSize != oldPainter.squareSize ||
      oddSquareColor != oldPainter.oddSquareColor ||
      evenSquareColor != oldPainter.evenSquareColor;
}

class _ImagePainter extends CustomPainter {
  const _ImagePainter(this.image);

  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(
      image,
      ui.Offset(
        (size.width - image.width) / 2,
        (size.height - image.height) / 2,
      ),
      ui.Paint(),
    );
  }

  @override
  bool shouldRepaint(_ImagePainter oldPainter) => image != oldPainter.image;
}
