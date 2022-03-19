import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:svg2iv_common/color_utils.dart';
import 'package:svg2iv_common/model/gradient.dart';
import 'package:svg2iv_common/model/vector_group.dart';
import 'package:svg2iv_common/model/vector_node.dart';
import 'package:svg2iv_common/model/vector_path.dart';
import 'package:tuple/tuple.dart';
import 'package:vector_math/vector_math.dart';

import 'extensions.dart';
import 'model/image_vector.dart';

extension ImageVectorToLottieJsonConversion on ImageVector? {
  List<int> toJson() => JsonUtf8Encoder().convert(_mapImageVector);
}

Map<String, dynamic>? _mapImageVector(ImageVector? imageVector) {
  if (imageVector == null) return null;
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
    'layers': nodes.map(_mapVectorNode),
  };
}

dynamic _mapVectorNode(VectorNode node) => node is VectorGroup
    ? _mapVectorGroup(node)
    : _mapVectorPath(node as VectorPath);

Map<String, dynamic> _mapVectorGroup(VectorGroup group) {
  return {
    /* TODO */
  };
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
  };
}

Map<String, dynamic> _mapPathFill(VectorPath path) {
  final Map<String, dynamic> fillShape;
  final pathFill = path.fill;
  if (pathFill == null || pathFill.colors.length <= 1) {
    final color = pathFill?.colors.singleOrNull ?? 0xFFFFFFFF;
    fillShape = {
      'ty': 'fl',
      'o': _getOpacityForColorInt(color, path.fillAlpha),
      'c': colorIntToRgbFractions(color),
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
    's': startPoint.storage,
    'e': endPoint.storage,
    'g': {
      'k': Iterable.generate(
        colorCount * 4 + colorCount * 2,
        (index) sync* {
          yield pathFill.stops[index];
          yield* colorIntToRgbFractions(pathFill.colors[index]);
        },
      ).flattened.toNonGrowableList()
        ..addAll(
          Iterable.generate((colorCount * 2), (index) sync* {
            yield pathFill.stops[index];
            yield alphaForColorInt(pathFill.colors[index]) / 255.0;
          }).flattened,
        ),
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
    'w': path.strokeLineWidth,
  };
  if (pathStroke.colors.length == 1) {
    final color = pathStroke.colors[0];
    strokeShape['o'] = _getOpacityForColorInt(color, path.strokeAlpha);
    strokeShape['c'] = colorIntToRgbFractions(color);
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
    final irList =
        nodes.map(_getIntermediateRepresentationForNode).toNonGrowableList();
    final points = List<Tuple3<Vector2, Vector2, Vector2>>.generate(
      pointCount,
      (index) {
        final zero = Vector2.zero();
        if (index == 0) {
          final ir = irList[index];
          return Tuple3(
            zero,
            irList[index + 1].item1,
            ir is Vector2 ? ir : zero,
          );
        } else {
          final point = irList[index].item3;
          return Tuple3(
            irList[index - 1].item2 - point,
            (index < pointCount ? irList[index + 1].item1 : zero) - point,
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
      return Tuple3.fromList(
        arguments
            .chunked(2)
            .map((c) => Vector2(c[0], c[1]))
            .toNonGrowableList(),
      );
  }
}
