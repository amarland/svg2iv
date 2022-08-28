import 'package:meta/meta.dart';

import '../extensions.dart';
import 'brush.dart';

abstract class VectorNode {
  const VectorNode(this.id);

  final String? id;
}

abstract class VectorNodeBuilder<T extends VectorNode,
    B extends VectorNodeBuilder<T, B>> {
  String? _id;

  @protected
  String? get id_ => _id;

  Brush? _fill;

  @protected
  Brush? get fill_ => _fill;

  double? _alpha;

  @protected
  double? get alpha_ => _alpha;

  double? _fillAlpha;

  @protected
  double? get fillAlpha_ => _fillAlpha;

  Brush? _stroke;

  @protected
  Brush? get stroke_ => _stroke;

  double? _strokeAlpha;

  @protected
  double? get strokeAlpha_ => _strokeAlpha;

  double? _strokeLineWidth;

  @protected
  double? get strokeLineWidth_ => _strokeLineWidth;

  StrokeCap? _strokeLineCap;

  @protected
  StrokeCap? get strokeLineCap_ => _strokeLineCap;

  StrokeJoin? _strokeLineJoin;

  @protected
  StrokeJoin? get strokeLineJoin_ => _strokeLineJoin;

  double? _strokeLineMiter;

  @protected
  double? get strokeLineMiter_ => _strokeLineMiter;

  PathFillType? _pathFillType;

  @protected
  PathFillType? get pathFillType_ => _pathFillType;

  @protected
  bool get hasAttributes_ {
    return [
      _fill,
      _fillAlpha,
      _stroke,
      _strokeAlpha,
      _strokeLineWidth,
      _strokeLineCap,
      _strokeLineJoin,
      _strokeLineMiter,
      _pathFillType,
    ].anyNotNull();
  }

  /*
  double? _trimPathStart;
  double? _trimPathEnd;
  double? _trimPathOffset;
  */

  B id(String id) {
    _id = id;
    return this as B;
  }

  B fill(Brush fill) {
    _fill = fill;
    return this as B;
  }

  B alpha(double alpha) {
    _alpha = alpha;
    return this as B;
  }

  B fillAlpha(double fillAlpha) {
    _fillAlpha = fillAlpha;
    return this as B;
  }

  B stroke(Brush stroke) {
    _stroke = stroke;
    return this as B;
  }

  B strokeAlpha(double strokeAlpha) {
    _strokeAlpha = strokeAlpha;
    return this as B;
  }

  B strokeLineWidth(double strokeLineWidth) {
    _strokeLineWidth = strokeLineWidth;
    return this as B;
  }

  B strokeLineCap(StrokeCap strokeLineCap) {
    _strokeLineCap = strokeLineCap;
    return this as B;
  }

  B strokeLineJoin(StrokeJoin strokeLineJoin) {
    _strokeLineJoin = strokeLineJoin;
    return this as B;
  }

  B strokeLineMiter(double strokeLineMiter) {
    _strokeLineMiter = strokeLineMiter;
    return this as B;
  }

  B pathFillType(PathFillType pathFillType) {
    _pathFillType = pathFillType;
    return this as B;
  }

  T build();
}

enum PathFillType { nonZero, evenOdd }

PathFillType? pathFillTypeFromString(String valueAsString) {
  switch (valueAsString.toLowerCase()) {
    case 'nonzero':
      return PathFillType.nonZero;
    case 'evenodd':
      return PathFillType.evenOdd;
  }
  return null;
}

enum StrokeCap { butt, round, square }

StrokeCap? strokeCapFromString(String valueAsString) {
  switch (valueAsString) {
    case 'butt':
      return StrokeCap.butt;
    case 'round':
      return StrokeCap.round;
    case 'square':
      return StrokeCap.square;
  }
  return null;
}

enum StrokeJoin { bevel, miter, round }

StrokeJoin? strokeJoinFromString(String valueAsString) {
  switch (valueAsString) {
    case 'bevel':
      return StrokeJoin.bevel;
    case 'miter':
      return StrokeJoin.miter;
    case 'round':
      return StrokeJoin.round;
  }
  return null;
}

@protected
double? multiplyAlphas(double? alpha1, double? alpha2) =>
    alpha1 == null ? alpha2 : (alpha2 == null ? alpha1 : alpha1 * alpha2);
