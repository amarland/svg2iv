import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:svg2iv_common/utils.dart';
import 'package:svg2iv_common/models.dart';
import 'package:vector_math/vector_math_64.dart';

extension GroupTransformMatrixExtraction on VectorGroup {
  Float64List getTransform() {
    final translationX = translation?.x ?? VectorGroup.defaultTranslationX;
    final translationY = translation?.y ?? VectorGroup.defaultTranslationY;
    final scaleX = scale?.x ?? VectorGroup.defaultScaleX;
    final scaleY = scale?.y ?? VectorGroup.defaultScaleY;
    final pivotX = rotation?.pivotX ?? VectorGroup.defaultPivotX;
    final pivotY = rotation?.pivotY ?? VectorGroup.defaultPivotY;
    final angle = rotation?.angle ?? 0.0;
    final matrix = Matrix4.identity()
      ..translate(translationX + pivotX, translationY + pivotY)
      ..rotateZ(radians(angle))
      ..scale(scaleX, scaleY)
      ..translate(-pivotX, -pivotY);
    return matrix.storage;
  }
}

extension PathFillTypeToFlutterPathFillTypeMapping on PathFillType? {
  ui.PathFillType toFlutterPathFillType() {
    return this == PathFillType.nonZero
        ? ui.PathFillType.nonZero
        : ui.PathFillType.evenOdd;
  }
}

extension TileModeToFlutterTileModeMapping on TileMode? {
  ui.TileMode toFlutterTileMode() {
    final tileMode = this;
    return tileMode == null
        ? ui.TileMode.clamp
        : ui.TileMode.values.byName(tileMode.name);
  }
}

extension StrokeCapToFlutterStrokeCapMapping on StrokeCap? {
  ui.StrokeCap toFlutterStrokeCap() {
    final strokeCap = this;
    return strokeCap == null
        ? ui.StrokeCap.butt
        : ui.StrokeCap.values.byName(strokeCap.name);
  }
}

extension StrokeJoinToFlutterStrokeJoinMapping on StrokeJoin? {
  ui.StrokeJoin toFlutterStrokeJoin() {
    final strokeJoin = this;
    return strokeJoin == null
        ? ui.StrokeJoin.miter
        : ui.StrokeJoin.values.byName(strokeJoin.name);
  }
}

extension GradientToPaintMapping on Gradient {
  ui.Paint asPaint({double? alpha}) {
    final paint = ui.Paint();
    final gradient = this;
    if (gradient is LinearGradient) {
      if (gradient.colors.length == 1) {
        paint.color = ui.Color(gradient.colors[0]);
      } else {
        paint.shader = ui.Gradient.linear(
          ui.Offset(gradient.startX, gradient.startY),
          ui.Offset(gradient.endX, gradient.endY),
          gradient.colors.map(ui.Color.new).toNonGrowableList(),
          gradient.stops,
          gradient.tileMode.toFlutterTileMode(),
        );
      }
    } else {
      gradient as RadialGradient;
      paint.shader = ui.Gradient.radial(
        ui.Offset(gradient.centerX, gradient.centerY),
        gradient.radius,
        gradient.colors.map(ui.Color.new).toNonGrowableList(),
        gradient.stops,
        gradient.tileMode.toFlutterTileMode(),
      );
    }
    alpha?.takeIf((alpha) => alpha < 1.0)?.let((targetAlpha) {
      paint.color = paint.color.withAlpha(
        (targetAlpha * paint.color.alpha).round(),
      );
    });
    return paint;
  }
}

extension PathNodesToSvgPathDataStringMapping on List<PathNode> {
  String toSvgPathDataString() {
    const commandLetterMap = {
      PathDataCommand.close: 'Z',
      PathDataCommand.moveTo: 'M',
      PathDataCommand.relativeMoveTo: 'm',
      PathDataCommand.lineTo: 'L',
      PathDataCommand.relativeLineTo: 'l',
      PathDataCommand.horizontalLineTo: 'H',
      PathDataCommand.relativeHorizontalLineTo: 'h',
      PathDataCommand.verticalLineTo: 'V',
      PathDataCommand.relativeVerticalLineTo: 'v',
      PathDataCommand.curveTo: 'C',
      PathDataCommand.relativeCurveTo: 'c',
      PathDataCommand.smoothCurveTo: 'S',
      PathDataCommand.relativeSmoothCurveTo: 's',
      PathDataCommand.quadraticBezierCurveTo: 'Q',
      PathDataCommand.relativeQuadraticBezierCurveTo: 'q',
      PathDataCommand.smoothQuadraticBezierCurveTo: 'T',
      PathDataCommand.relativeSmoothQuadraticBezierCurveTo: 't',
      PathDataCommand.arcTo: 'A',
      PathDataCommand.relativeArcTo: 'a',
    };
    return map((segment) {
      return commandLetterMap[segment.command]! +
          (segment.command != PathDataCommand.close ? ' ' : '') +
          segment.arguments
              .map((value) => value is bool
                  ? (value ? '1' : '0')
                  : (value as double).toStringWithMaxDecimals(5))
              .join(' ');
    }).join(' ');
  }
}
