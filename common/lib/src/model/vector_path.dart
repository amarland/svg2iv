import 'package:collection/collection.dart' show ListEquality;

import '../extensions.dart';
import 'brush.dart';
import 'path_node.dart';
import 'vector_node.dart';

class VectorPath extends VectorNode {
  static final defaultFill = const SolidColor(0xFF000000);
  static const defaultFillAlpha = 1.0;
  static const defaultStrokeAlpha = 1.0;
  static const defaultStrokeLineWidth = 1.0;
  static const defaultStrokeLineCap = StrokeCap.butt;
  static const defaultStrokeLineJoin = StrokeJoin.miter;
  static const defaultStrokeLineMiter = 4.0;
  static const defaultPathFillType = PathFillType.nonZero;
  static const defaultTrimPathStart = 0.0;
  static const defaultTrimPathEnd = 1.0;
  static const defaultTrimPathOffset = 0.0;

  const VectorPath._(
    this.pathData, {
    String? id,
    this.fill,
    this.fillAlpha,
    this.stroke,
    this.strokeAlpha,
    this.strokeLineWidth,
    this.strokeLineCap,
    this.strokeLineJoin,
    this.strokeLineMiter,
    this.pathFillType,
    this.trimPathStart,
    this.trimPathEnd,
    this.trimPathOffset,
  }) : super(id);

  final List<PathNode> pathData;
  final Brush? fill;
  final double? fillAlpha;
  final Brush? stroke;
  final double? strokeAlpha;
  final double? strokeLineWidth;
  final StrokeCap? strokeLineCap;
  final StrokeJoin? strokeLineJoin;
  final double? strokeLineMiter;
  final PathFillType? pathFillType;
  final double? trimPathStart, trimPathEnd, trimPathOffset;

  bool get hasAttributes => [
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
        trimPathStart,
        trimPathEnd,
        trimPathOffset,
      ].anyNotNull();

  VectorPath copyWith({
    List<PathNode>? pathData,
    String? id,
    Brush? fill,
    double? fillAlpha,
    Brush? stroke,
    double? strokeAlpha,
    double? strokeLineWidth,
    StrokeCap? strokeLineCap,
    StrokeJoin? strokeLineJoin,
    double? strokeLineMiter,
    PathFillType? pathFillType,
    double? trimPathStart,
    double? trimPathEnd,
    double? trimPathOffset,
  }) {
    return VectorPath._(
      pathData ?? this.pathData,
      id: id ?? this.id,
      fill: fill ?? this.fill,
      fillAlpha: fillAlpha ?? this.fillAlpha,
      stroke: stroke ?? this.stroke,
      strokeAlpha: strokeAlpha ?? this.strokeAlpha,
      strokeLineWidth: strokeLineWidth ?? this.strokeLineWidth,
      strokeLineCap: strokeLineCap ?? this.strokeLineCap,
      strokeLineJoin: strokeLineJoin ?? this.strokeLineJoin,
      strokeLineMiter: strokeLineMiter ?? this.strokeLineMiter,
      pathFillType: pathFillType ?? this.pathFillType,
      trimPathStart: trimPathStart ?? this.trimPathStart,
      trimPathEnd: trimPathEnd ?? this.trimPathEnd,
      trimPathOffset: trimPathOffset ?? this.trimPathOffset,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VectorPath &&
          runtimeType == other.runtimeType &&
          const ListEquality<PathNode>().equals(pathData, other.pathData) &&
          fill == other.fill &&
          fillAlpha == other.fillAlpha &&
          stroke == other.stroke &&
          strokeAlpha == other.strokeAlpha &&
          strokeLineWidth == other.strokeLineWidth &&
          strokeLineCap == other.strokeLineCap &&
          strokeLineJoin == other.strokeLineJoin &&
          strokeLineMiter == other.strokeLineMiter &&
          pathFillType == other.pathFillType &&
          trimPathStart == other.trimPathStart &&
          trimPathEnd == other.trimPathEnd &&
          trimPathOffset == other.trimPathOffset;

  @override
  int get hashCode =>
      const ListEquality<PathNode>().hash(pathData) ^
      fill.hashCode ^
      fillAlpha.hashCode ^
      stroke.hashCode ^
      strokeAlpha.hashCode ^
      strokeLineWidth.hashCode ^
      strokeLineCap.hashCode ^
      strokeLineJoin.hashCode ^
      strokeLineMiter.hashCode ^
      pathFillType.hashCode ^
      trimPathStart.hashCode ^
      trimPathEnd.hashCode ^
      trimPathOffset.hashCode;
}

class VectorPathBuilder
    extends VectorNodeBuilder<VectorPath, VectorPathBuilder> {
  VectorPathBuilder(this._pathData);

  final List<PathNode> _pathData;
  Brush? _fill;
  double? _fillAlpha;
  Brush? _stroke;
  double? _strokeAlpha;
  double? _strokeLineWidth;
  StrokeCap? _strokeLineCap;
  StrokeJoin? _strokeLineJoin;
  double? _strokeLineMiter;
  PathFillType? _pathFillType;
  double? _trimPathStart, _trimPathEnd, _trimPathOffset;

  VectorPathBuilder fill(Brush fill) {
    _fill = fill;
    return this;
  }

  VectorPathBuilder fillAlpha(double fillAlpha) {
    _fillAlpha = fillAlpha;
    return this;
  }

  VectorPathBuilder stroke(Brush stroke) {
    _stroke = stroke;
    return this;
  }

  VectorPathBuilder strokeAlpha(double strokeAlpha) {
    _strokeAlpha = strokeAlpha;
    return this;
  }

  VectorPathBuilder strokeLineWidth(double strokeLineWidth) {
    _strokeLineWidth = strokeLineWidth;
    return this;
  }

  VectorPathBuilder strokeLineCap(StrokeCap strokeLineCap) {
    _strokeLineCap = strokeLineCap;
    return this;
  }

  VectorPathBuilder strokeLineJoin(StrokeJoin strokeLineJoin) {
    _strokeLineJoin = strokeLineJoin;
    return this;
  }

  VectorPathBuilder strokeLineMiter(double strokeLineMiter) {
    _strokeLineMiter = strokeLineMiter;
    return this;
  }

  VectorPathBuilder pathFillType(PathFillType pathFillType) {
    _pathFillType = pathFillType;
    return this;
  }

  VectorPathBuilder trimPathStart(double trimPathStart) {
    _trimPathStart = trimPathStart;
    return this;
  }

  VectorPathBuilder trimPathEnd(double trimPathEnd) {
    _trimPathEnd = trimPathEnd;
    return this;
  }

  VectorPathBuilder trimPathOffset(double trimPathOffset) {
    _trimPathOffset = trimPathOffset;
    return this;
  }

  @override
  VectorPath build() {
    final strokeLineWidth = _strokeLineWidth;
    final isStroked =
        _stroke != null && strokeLineWidth != null && strokeLineWidth > 0.0;
    return VectorPath._(
      _pathData,
      id: id_,
      fill: _fill,
      fillAlpha: _fill != null ? _fillAlpha : null,
      stroke: _stroke,
      strokeAlpha: isStroked ? _strokeAlpha : null,
      strokeLineWidth: isStroked ? _strokeLineWidth : null,
      strokeLineCap: isStroked ? _strokeLineCap : null,
      strokeLineJoin: isStroked ? _strokeLineJoin : null,
      strokeLineMiter: isStroked ? _strokeLineMiter : null,
      pathFillType: _pathFillType,
      trimPathStart: _trimPathStart,
      trimPathEnd: _trimPathEnd,
      trimPathOffset: _trimPathOffset,
    );
  }
}
