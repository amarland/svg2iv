import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:svg2iv_common/model/image_vector.dart';
import 'package:svg2iv_common/model/vector_group.dart';
import 'package:svg2iv_common/model/vector_node.dart';
import 'package:svg2iv_common/model/vector_path.dart';

import 'extensions.dart';
import 'vector_path_command_interpreter.dart';

extension ImageVectorPainting on ImageVector {
  ui.Picture toPicture(ui.Size size) {
    // https://github.com/flutter/flutter/issues/83872
    final ui.Path reusablePath = ui.Path();
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final viewBox = ui.Rect.fromLTWH(0.0, 0.0, viewportWidth, viewportHeight);
    final ui.Canvas canvas = ui.Canvas(recorder, viewBox);
    if (size.width != viewportWidth || size.height != viewportHeight) {
      canvas.scale(size.width / viewportWidth, size.height / viewportHeight);
    }
    canvas.clipRect(viewBox);
    for (final node in nodes) {
      _paintVectorNode(node, canvas, reusablePath);
    }
    return recorder.endRecording();
  }
}

void _paintVectorNode(
  VectorNode vectorNode,
  ui.Canvas canvas,
  ui.Path reusablePath,
) {
  if (vectorNode is VectorGroup) {
    final applyTransformations = vectorNode.definesTransformations;
    if (applyTransformations) {
      canvas.save();
      canvas.transform(vectorNode.getTransform());
      final clipPathData = vectorNode.clipPathData;
      if (clipPathData != null && clipPathData.isNotEmpty) {
        interpretPathCommands(clipPathData, reusablePath);
        canvas.clipPath(reusablePath);
      }
    }
    for (final node in vectorNode.nodes) {
      _paintVectorNode(node, canvas, reusablePath);
    }
    if (applyTransformations) {
      canvas.restore();
    }
  } else {
    _paintVectorPath(vectorNode as VectorPath, canvas, reusablePath);
  }
}

void _paintVectorPath(
  VectorPath vectorPath,
  ui.Canvas canvas,
  ui.Path reusablePath,
) {
  interpretPathCommands(vectorPath.pathData, reusablePath);
  final pathFillType = vectorPath.pathFillType ?? PathFillType.nonZero;
  reusablePath.fillType = pathFillType.toFlutterPathFillType();
  canvas.drawPath(
    reusablePath,
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
    canvas.drawPath(reusablePath, strokePaint);
  }
}
