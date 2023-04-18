import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:svg2iv_common/utils.dart';
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
    return CustomPaint(
      painter: _CheckerboardPainter(
        oddSquareColor:
            widget.oddSquareColor ?? colors.onInverseSurface.withOpacity(0.5),
        evenSquareColor:
            widget.oddSquareColor ?? colors.onSurfaceVariant.withOpacity(0.5),
      ),
      foregroundPainter: _cachedImage?.let(_ImagePainter.new),
      child: widget.imageVector == null
          ? const SizedBox(
              width: 48.0,
              height: 48.0,
              child: CircularProgressIndicator(),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _cachedImage?.dispose();
    super.dispose();
  }

  void _updateState([Checkerboard? oldWidget]) {
    final imageVector = widget.imageVector;
    if (imageVector != null) {
      final size = widget.size;
      if (oldWidget == null ||
          _cachedImage == null ||
          imageVector != oldWidget.imageVector ||
          size != oldWidget.size) {
        final picture = imageVector.toPicture(size);
        final image = picture.toImageSync(
          size.width.floor(),
          size.height.floor(),
        );
        picture.dispose();
        _cachedImage?.dispose();
        setState(() {
          _cachedImage = image;
        });
      }
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
    /*
    canvas.drawRect(
      ui.Rect.fromLTWH(0.0, 0.0, size.width, size.height),
      Paint()..color = Colors.deepPurple.withOpacity(0.5),
    );
    */
    var odd = true;
    final paint = Paint()..isAntiAlias = false;
    while (y < actualHeight) {
      canvas.drawRect(
        Rect.fromLTWH(x, y, squareSize, squareSize),
        paint..color = odd ? oddSquareColor : evenSquareColor,
      );
      if (x + squareSize < size.width - offsetX) {
        x += squareSize;
      } else {
        x = (y + squareSize) % (squareSize);
        y += squareSize;
      }
      odd = !odd;
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
    const scaleFactor = 0.925;
    final offsetX = (size.width - size.width * scaleFactor) / 2,
        offsetY = (size.height - size.height * scaleFactor) / 2;
    canvas.scale(scaleFactor, scaleFactor);
    canvas.translate(offsetX, offsetY);
    canvas.drawImage(
      picture,
      const ui.Offset(0.0, 0.0),
      ui.Paint(),
    );
  }

  @override
  bool shouldRepaint(_ImagePainter oldPainter) => picture != oldPainter.picture;
}
