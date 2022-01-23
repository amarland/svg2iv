import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:svg2iv_common/model/image_vector.dart';
import 'package:svg2iv_common/model/vector_group.dart';
import 'package:svg2iv_common/model/vector_node.dart';
import 'package:svg2iv_common/model/vector_path.dart';

import '../util/extensions.dart';
import '../util/vector_path_command_interpreter.dart';

class ImageVectorPainter extends StatelessWidget {
  const ImageVectorPainter({
    Key? key,
    required this.imageVector,
    this.size,
  }) : super(key: key);

  final ImageVector imageVector;
  final Size? size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ImageVectorPainter(imageVector: imageVector),
    );
  }
}

class _ImageVectorPainter extends CustomPainter {
  _ImageVectorPainter({required this.imageVector}) : _path = ui.Path();

  final ImageVector imageVector;
  final ui.Path _path; // https://github.com/flutter/flutter/issues/83872

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final width = size.width;
    final height = size.height;
    final viewportWidth = imageVector.viewportWidth;
    final viewportHeight = imageVector.viewportHeight;
    if (width != viewportWidth || height != viewportHeight) {
      canvas.scale(width / viewportWidth, height / viewportHeight);
    }
    canvas.clipRect(ui.Rect.fromLTWH(0.0, 0.0, viewportWidth, viewportHeight));
    for (final node in imageVector.nodes) {
      _paintVectorNode(node, canvas);
    }
  }

  void _paintVectorNode(VectorNode vectorNode, Canvas canvas) {
    if (vectorNode is VectorGroup) {
      final applyTransformations = vectorNode.definesTransformations;
      if (applyTransformations) {
        canvas.save();
        canvas.transform(vectorNode.getTransform());
        final clipPathData = vectorNode.clipPathData;
        if (clipPathData != null && clipPathData.isNotEmpty) {
          interpretPathCommands(clipPathData, _path);
          canvas.clipPath(_path);
          _path.reset();
        }
      }
      for (final node in vectorNode.nodes) {
        _paintVectorNode(node, canvas);
      }
      if (applyTransformations) {
        canvas.restore();
      }
    } else {
      _paintVectorPath(vectorNode as VectorPath, canvas);
    }
  }

  void _paintVectorPath(VectorPath vectorPath, ui.Canvas canvas) {
    interpretPathCommands(vectorPath.pathData, _path);
    final pathFillType = vectorPath.pathFillType ?? PathFillType.nonZero;
    _path.fillType = pathFillType.toFlutterPathFillType();
    canvas.drawPath(
      _path,
      // no fill => black by default
      vectorPath.fill?.asPaint(alpha: vectorPath.fillAlpha) ?? Paint(),
    );
    final stroke = vectorPath.stroke;
    if (stroke != null) {
      final strokePaint = stroke.asPaint(alpha: vectorPath.strokeAlpha)
        ..style = ui.PaintingStyle.stroke
        ..strokeCap = vectorPath.strokeLineCap.toFlutterStrokeCap()
        ..strokeJoin = vectorPath.strokeLineJoin.toFlutterStrokeJoin()
        ..strokeMiterLimit =
            vectorPath.strokeLineMiter ?? VectorPath.defaultStrokeLineMiter
        ..strokeWidth =
            vectorPath.strokeLineWidth ?? VectorPath.defaultStrokeLineWidth;
      canvas.drawPath(_path, strokePaint);
    }
    _path.reset();
  }

  @override
  bool shouldRepaint(_ImageVectorPainter oldPainter) =>
      oldPainter.imageVector != imageVector;
}
