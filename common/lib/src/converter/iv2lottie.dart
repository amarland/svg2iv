import 'dart:convert';

import 'package:tuple/tuple.dart';
import 'package:vector_math/vector_math.dart';

import '../../models.dart';
import '../../utils.dart';

typedef _Vector2Triple = Tuple3<Vector2, Vector2, Vector2>;

extension ImageVectorToLottieJsonConversion on ImageVector {
  List<int> toLottieJson() => JsonUtf8Encoder(
        null,
        (obj) => obj is Iterable
            ? obj.toNonGrowableList()
            : throw JsonUnsupportedObjectError(obj),
      ).convert(_mapImageVector(this));
}

Map<String, dynamic> _mapImageVector(ImageVector imageVector) {
  final nodes = imageVector.nodes.any((node) => node is VectorPath)
      ? [
          VectorGroupBuilder()
              .also((b) => imageVector.nodes.forEach(b.addNode))
              .build()
        ]
      : imageVector.nodes;
  return {
    'nm': imageVector.name,
    'ip': 0,
    'op': 1,
    'fr': 1,
    'w': imageVector.viewportWidth,
    'h': imageVector.viewportHeight,
    'layers': [
      {
        'ty': 4,
        'ks': {'o': 100.0.toNonAnimatedProperty()},
        'shapes': nodes.reversed.map(_mapVectorNode).toNonGrowableList(),
      },
    ],
  }..removeWhereValueIsNull();
}

dynamic _mapVectorNode(VectorNode node) => node is VectorGroup
    ? _mapVectorGroup(node)
    : _mapVectorPath(node as VectorPath);

Map<String, dynamic> _mapVectorGroup(VectorGroup group) {
  return {
    'nm': group.id,
    'ty': 'gr',
    'a': group.rotation
        ?.let(
          (it) => [
            it.pivotX ?? VectorGroup.defaultPivotX,
            it.pivotY ?? VectorGroup.defaultPivotY,
          ],
        )
        .toNonAnimatedProperty(),
    'p': group.translation?.let((it) => [it.x, it.y]).toNonAnimatedProperty(),
    's': group.scale
        ?.let(
          (it) => [
            it.x * 100.0,
            (it.y ?? VectorGroup.defaultScaleY) * 100.0,
          ],
        )
        .toNonAnimatedProperty(),
    'r': group.rotation?.angle.toNonAnimatedProperty(),
    'it': group.nodes.reversed.map(_mapVectorNode),
  }..removeWhereValueIsNull();
}

Map<String, dynamic> _mapVectorPath(VectorPath path) {
  final pathId = path.id;
  final pathShapes = _mapPathShapes(path, pathId);
  final strokeShape = _mapPathStroke(path);
  return {
    'nm': pathId,
    'ty': 'gr',
    'it': pathShapes
      ..add(_mapPathFill(path))
      ..also((shapes) {
        if (strokeShape != null) {
          shapes.add(strokeShape);
        }
        if (path.trimPathStart != null || path.trimPathEnd != null) {
          shapes.add({
            'ty': 'tm',
            's': path.trimPathStart,
            'e': path.trimPathEnd,
            'o': path.trimPathOffset
          }..removeWhereValueIsNull());
        }
      }),
  }..removeWhereValueIsNull();
}

Map<String, dynamic> _mapPathFill(VectorPath path) {
  final Map<String, dynamic> fillShape;
  final pathFill = path.fill;
  if (pathFill == null || pathFill.colors.length <= 1) {
    final color = pathFill?.colors.singleOrNull ?? 0xFFFFFFFF;
    fillShape = {
      'ty': 'fl',
      'o': _getOpacityForColorInt(
        color,
        path.fillAlpha,
      ).toNonAnimatedProperty(),
      'c': colorIntToRgbFractions(color).toNonAnimatedProperty(),
      'r': path.pathFillType == PathFillType.evenOdd ? 2 : 1,
    };
  } else {
    fillShape = _mapGradient(pathFill)..['ty'] = 'gf';
  }
  return fillShape;
}

Map<String, dynamic> _mapGradient(Gradient pathFill) {
  final Vector2 startPoint;
  final Vector2 endPoint;
  if (pathFill is LinearGradient) {
    startPoint = Vector2(pathFill.startX, pathFill.startY);
    endPoint = Vector2(pathFill.endX, pathFill.endY);
  } else {
    pathFill as RadialGradient;
    startPoint = Vector2(pathFill.centerX, pathFill.centerY);
    endPoint = startPoint + Vector2(pathFill.radius, 0.0);
  }
  final colorCount = pathFill.colors.length;
  return {
    't': pathFill is LinearGradient ? 1 : 2,
    's': startPoint.storage.toNonAnimatedProperty(),
    'e': endPoint.storage.toNonAnimatedProperty(),
    'g': {
      'k': Iterable.generate(
        colorCount * 4 + colorCount * 2,
        (index) sync* {
          yield pathFill.stops[index];
          yield* colorIntToRgbFractions(pathFill.colors[index]);
        },
      )..flattened.toNonGrowableList().also((it) {
          it.addAll(
            Iterable.generate((colorCount * 2), (index) sync* {
              yield pathFill.stops[index];
              yield alphaForColorInt(pathFill.colors[index]) / 255.0;
            }).flattened,
          );
        }).toNonAnimatedProperty(),
      'p': colorCount,
    },
  };
}

Map<String, dynamic>? _mapPathStroke(VectorPath path) {
  final pathStroke = path.stroke;
  if (pathStroke == null) {
    return null;
  }
  final lineCap = path.strokeLineCap;
  final lineCapIndex = lineCap != null
      ? [StrokeCap.butt, StrokeCap.round, StrokeCap.square].indexOf(lineCap)
      : -1;
  final lineJoin = path.strokeLineJoin;
  final lineJoinIndex = lineJoin != null
      ? [StrokeJoin.miter, StrokeJoin.round, StrokeJoin.bevel].indexOf(lineJoin)
      : -1;
  final strokeShape = {
    'ty': 'st',
    'lc': lineCapIndex > -1 ? lineCapIndex + 1 : null,
    'lj': lineJoinIndex > -1 ? lineJoinIndex + 1 : null,
    'ml': path.strokeLineMiter,
    'w': path.strokeLineWidth.toNonAnimatedProperty(),
  };
  if (pathStroke.colors.length == 1) {
    final color = pathStroke.colors[0];
    strokeShape['o'] = _getOpacityForColorInt(
      color,
      path.strokeAlpha,
    ).toNonAnimatedProperty();
    strokeShape['c'] = colorIntToRgbFractions(color).toNonAnimatedProperty();
  } else {
    strokeShape
      ..addAll(_mapGradient(pathStroke))
      ..['ty'] = 'gs';
  }
  return strokeShape..removeWhereValueIsNull();
}

double _getOpacityForColorInt(int color, double? alpha) =>
    100.0 * (alpha ?? 1.0) * (alphaForColorInt(color));

List<Map<String, Object?>> _mapPathShapes(VectorPath path, String? pathId) {
  final List<List<PathNode>> paths = path.pathData
      .splitBefore((node) => node.command == PathDataCommand.moveTo)
      .toNonGrowableList();
  final pathShapes = paths.mapIndexed((pathIndex, nodes) {
    final isClosed = nodes.last.command == PathDataCommand.close;
    final pointCount = isClosed ? nodes.length - 1 : nodes.length;
    final irList = (isClosed ? nodes.slice(0, pointCount) : nodes)
        .map(_getIntermediateRepresentationForNode)
        .toList();
    final points = List<_Vector2Triple>.generate(
      pointCount,
      (index) {
        final zero = Vector2.zero();
        if (index == 0) {
          final ir = irList[index];
          return Tuple3(
            zero,
            irList[index + 1].item1 as Vector2,
            ir is Vector2 ? ir : zero,
          );
        } else {
          final point = (irList[index] as _Vector2Triple).item3;
          final previousIr = irList[index - 1];
          final nextIr = irList[index + 1] as _Vector2Triple;
          return Tuple3(
            (previousIr is _Vector2Triple ? previousIr.item2 : zero) - point,
            (index < pointCount ? nextIr.item1 : zero) - point,
            point,
          );
        }
      },
    );
    return {
      'nm': pathId != null ? '${pathId}_$pathIndex' : null,
      'ty': 'sh',
      'ks': {
        'c': isClosed,
        'i': points.map((tuple) => tuple.item1.storage),
        'o': points.map((tuple) => tuple.item2.storage),
        'v': points.map((tuple) => tuple.item3.storage),
      },
    };
  }).toList(growable: true);
  return pathShapes;
}

/*
 * Returns either:
 * - a `Tuple3<Vector2, Vector2, Vector2>`, where:
 *   + `item1`: first control point
 *   + `item2`: second control point
 *   + `item3`: end point
 * - a `Vector2`, the initial point
 */
dynamic _getIntermediateRepresentationForNode(PathNode node) {
  final arguments = node.arguments.cast<double>();
  switch (node.command) {
    case PathDataCommand.moveTo:
      return Vector2(arguments[0], arguments[1]);
    case PathDataCommand.lineTo:
      return Tuple3(
        Vector2.zero(),
        Vector2.zero(),
        Vector2(arguments[0], arguments[1]),
      );
    default:
      return _Vector2Triple.fromList(
        arguments
            .chunked(2)
            .map((c) => Vector2(c[0], c[1]))
            .toNonGrowableList(),
      );
  }
}

extension AnimatedPropertyCreation<T> on T {
  Map<String, dynamic> toNonAnimatedProperty() => {'a': 0, 'k': this};
}
