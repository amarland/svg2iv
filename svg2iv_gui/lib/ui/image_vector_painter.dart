import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:svg2iv_common/extensions.dart';
import 'package:svg2iv_common/model/gradient.dart' as svg2iv_gradient;
import 'package:svg2iv_common/model/image_vector.dart';
import 'package:svg2iv_common/model/vector_group.dart';
import 'package:svg2iv_common/model/vector_node.dart';
import 'package:svg2iv_common/model/vector_path.dart';
import 'package:svg2iv_gui/util/vector_path_command_interpreter.dart';
import 'package:vector_math/vector_math_64.dart';

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
  _ImageVectorPainter({required this.imageVector})
      : _matrix = Matrix4.identity(),
        _path = ui.Path();

  final ImageVector imageVector;
  final Matrix4 _matrix;
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
    for (final node in imageVector.nodes) {
      _paintVectorNode(node, canvas);
    }
  }

  void _paintVectorNode(VectorNode vectorNode, Canvas canvas) {
    if (vectorNode is VectorGroup) {
      final applyTransformations = vectorNode.definesTransformations;
      if (applyTransformations) {
        canvas.save();
        _matrix.setIdentity();
        final translationX =
            vectorNode.translation?.x ?? VectorGroup.defaultTranslationX;
        final translationY =
            vectorNode.translation?.y ?? VectorGroup.defaultTranslationY;
        final scaleX = vectorNode.scale?.x ?? VectorGroup.defaultScaleX;
        final scaleY = vectorNode.scale?.y ?? VectorGroup.defaultScaleY;
        final pivotX = vectorNode.rotation?.pivotX ?? VectorGroup.defaultPivotX;
        final pivotY = vectorNode.rotation?.pivotY ?? VectorGroup.defaultPivotY;
        final angle = vectorNode.rotation?.angle ?? 0.0;
        _matrix.translate(translationX + pivotX, translationY + pivotY);
        _matrix.rotateZ(radians(angle));
        _matrix.scale(scaleX, scaleY, 1.0);
        _matrix.translate(-pivotX, -pivotY);
        canvas.transform(_matrix.storage);
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
      vectorNode as VectorPath;
      interpretPathCommands(vectorNode.pathData, _path);
      final pathFillType = vectorNode.pathFillType ?? PathFillType.nonZero;
      _path.fillType = pathFillType == PathFillType.nonZero
          ? ui.PathFillType.nonZero
          : ui.PathFillType.evenOdd;
      final fillPaint = _obtainPaintFromGradient(
        vectorNode.fill,
        vectorNode.fillAlpha,
      );
      canvas.drawPath(_path, fillPaint);
      if (vectorNode.stroke != null) {
        final strokePaint = _obtainPaintFromGradient(
          vectorNode.stroke,
          vectorNode.strokeAlpha,
        )..style = ui.PaintingStyle.stroke;
        vectorNode.strokeLineCap?.let((cap) =>
            strokePaint.strokeCap = ui.StrokeCap.values.byName(cap.name));
        vectorNode.strokeLineJoin?.let((join) =>
            strokePaint.strokeJoin = ui.StrokeJoin.values.byName(join.name));
        strokePaint.strokeMiterLimit =
            vectorNode.strokeLineMiter ?? VectorPath.defaultStrokeLineMiter;
        strokePaint.strokeWidth =
            vectorNode.strokeLineWidth ?? VectorPath.defaultStrokeLineWidth;
        canvas.drawPath(_path, strokePaint);
      }
      _path.reset();
    }
  }

  ui.Paint _obtainPaintFromGradient(
    svg2iv_gradient.Gradient? fill,
    double? alpha,
  ) {
    final Paint paint = ui.Paint();
    if (fill == null) return paint;
    if (fill is svg2iv_gradient.LinearGradient) {
      if (fill.colors.length == 1) {
        paint.color = Color(fill.colors[0]);
      } else {
        paint.shader = ui.Gradient.linear(
          ui.Offset(fill.startX, fill.startY),
          ui.Offset(fill.endX, fill.endY),
          fill.colors.map(ui.Color.new).toList(),
          fill.stops,
          _convertTileMode(fill.tileMode),
        );
      }
    } else {
      fill as svg2iv_gradient.RadialGradient;
      paint.shader = ui.Gradient.radial(
        ui.Offset(fill.centerX, fill.centerY),
        fill.radius,
        fill.colors.map(ui.Color.new).toList(),
        fill.stops,
        _convertTileMode(fill.tileMode),
      );
    }
    alpha?.takeIf((alpha) => alpha < 1.0)?.let((targetAlpha) {
      paint.color =
          paint.color.withAlpha((targetAlpha * paint.color.alpha).round());
    });
    return paint;
  }

  ui.TileMode _convertTileMode(svg2iv_gradient.TileMode? tileMode) =>
      tileMode == null
          ? ui.TileMode.clamp
          : ui.TileMode.values.byName(tileMode.name);

  @override
  bool shouldRepaint(_ImageVectorPainter oldPainter) =>
      oldPainter.imageVector != imageVector;
}
