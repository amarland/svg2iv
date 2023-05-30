import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:svg2iv_common/extensions.dart';
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

extension BrushToPaintMapping on Brush {
  ui.Paint asPaint({double? alpha}) {
    final paint = ui.Paint();
    final brush = this;
    if (brush is SolidColor) {
      paint.color = ui.Color(brush.colorInt);
    } else if (brush is LinearGradient) {
      paint.shader = ui.Gradient.linear(
        ui.Offset(brush.startX, brush.startY),
        ui.Offset(brush.endX, brush.endY),
        brush.colors.map(ui.Color.new).toList(),
        brush.stops,
        brush.tileMode.toFlutterTileMode(),
      );
    } else {
      brush as RadialGradient;
      paint.shader = ui.Gradient.radial(
        ui.Offset(brush.centerX, brush.centerY),
        brush.radius,
        brush.colors.map(ui.Color.new).toList(),
        brush.stops,
        brush.tileMode.toFlutterTileMode(),
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
    return map((segment) {
      final letter = switch (segment.command) {
        PathDataCommand.moveTo => 'M',
        PathDataCommand.lineTo => 'L',
        PathDataCommand.curveTo => 'C',
        PathDataCommand.arcTo => 'A',
        PathDataCommand.close => 'Z',
      };
      return letter +
          (segment.command != PathDataCommand.close ? ' ' : '') +
          segment.arguments
              .map((value) => value is bool
                  ? (value ? '1' : '0')
                  : (value as double).toStringWithMaxDecimals(5))
              .join(' ');
    }).join(' ');
  }
}
