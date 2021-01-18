import 'package:meta/meta.dart';
import 'package:svg2va/extensions.dart';
import 'package:svg2va/model/gradient.dart';
import 'package:svg2va/model/identifiable.dart';

abstract class VectorNode extends Identifiable {
  const VectorNode(String? id) : super(id);
}

abstract class VectorNodeBuilder<T extends VectorNode,
    B extends VectorNodeBuilder<T, B>> {
  String? _id;

  @protected
  String? get id_ => _id;

  Gradient? _fill;

  @protected
  Gradient? get fill_ => _fill;

  double? _fillAlpha;

  @protected
  double? get fillAlpha_ => _fillAlpha;

  Gradient? _stroke;

  @protected
  Gradient? get stroke_ => _stroke;

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
  bool get hasAttributes_ => [
        id,
        fill,
        fillAlpha,
        stroke,
        strokeAlpha,
        strokeLineWidth,
        strokeLineCap,
        strokeLineJoin,
        strokeLineMiter,
        pathFillType,
      ].anyNotNull();

  /*
  double? _trimPathStart;
  double? _trimPathEnd;
  double? _trimPathOffset;
  */

  B id(String id) {
    _id = id;
    return this as B;
  }

  B fill(Gradient fill) {
    _fill = fill;
    return this as B;
  }

  B fillAlpha(double fillAlpha) {
    _fillAlpha = fillAlpha;
    return this as B;
  }

  B stroke(Gradient stroke) {
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

enum StrokeCap { butt, round, square }

enum StrokeJoin { miter, round, bevel }
