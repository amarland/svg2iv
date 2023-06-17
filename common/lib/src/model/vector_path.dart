import 'package:equatable/equatable.dart';

import '../extensions.dart';
import 'brush.dart';
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

  const VectorPath._init(
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
  final double? trimPathStart;
  final double? trimPathEnd;
  final double? trimPathOffset;

  bool get hasAttributes {
    return [
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
  }

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
    return VectorPath._init(
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
  List<Object?> get props {
    return super.props
      ..addAll([
        pathData,
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
      ]);
  }
}

class VectorPathBuilder
    extends VectorNodeBuilder<VectorPath, VectorPathBuilder> {
  VectorPathBuilder(this._pathData);

  final List<PathNode> _pathData;
  double? _trimPathStart;
  double? _trimPathEnd;
  double? _trimPathOffset;

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
    final strokeLineWidth = strokeLineWidth_;
    final isStroked =
        stroke_ != null && strokeLineWidth != null && strokeLineWidth > 0.0;
    return VectorPath._init(
      _pathData,
      id: id_,
      fill: fill_,
      fillAlpha: fill_ != null ? multiplyAlphas(fillAlpha_, alpha_) : null,
      stroke: stroke_,
      strokeAlpha: isStroked ? multiplyAlphas(strokeAlpha_, alpha_) : null,
      strokeLineWidth: isStroked ? strokeLineWidth : null,
      strokeLineCap: isStroked ? strokeLineCap_ : null,
      strokeLineJoin: isStroked ? strokeLineJoin_ : null,
      strokeLineMiter: isStroked ? strokeLineMiter_ : null,
      pathFillType: pathFillType_,
      trimPathStart: _trimPathStart,
      trimPathEnd: _trimPathEnd,
      trimPathOffset: _trimPathOffset,
    );
  }
}

enum PathDataCommand {
  close,
  moveTo,
  relativeMoveTo,
  lineTo,
  relativeLineTo,
  horizontalLineTo,
  relativeHorizontalLineTo,
  verticalLineTo,
  relativeVerticalLineTo,
  curveTo,
  relativeCurveTo,
  smoothCurveTo,
  relativeSmoothCurveTo,
  quadraticBezierCurveTo,
  relativeQuadraticBezierCurveTo,
  smoothQuadraticBezierCurveTo,
  relativeSmoothQuadraticBezierCurveTo,
  arcTo,
  relativeArcTo,
}

class PathNode extends Equatable {
  // TODO: add named constructors for each command?
  const PathNode(this.command, this.arguments);

  final PathDataCommand command;
  final List<dynamic> arguments;

  @override
  List<Object?> get props => [command, arguments];
}
