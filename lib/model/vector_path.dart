import 'package:collection/collection.dart' show ListEquality;
import 'package:svg2iv/extensions.dart';
import 'package:svg2iv/model/gradient.dart';
import 'package:svg2iv/model/vector_node.dart';

class VectorPath extends VectorNode {
  VectorPath._init(
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
    /*
    this.trimPathStart,
    this.trimPathEnd,
    this.trimPathOffset,
    */
  }) : super(id);

  final List<PathNode> pathData;
  final Gradient? fill;
  final double? fillAlpha;
  final Gradient? stroke;
  final double? strokeAlpha;
  final double? strokeLineWidth;
  final StrokeCap? strokeLineCap;
  final StrokeJoin? strokeLineJoin;
  final double? strokeLineMiter;
  final PathFillType? pathFillType;

  /*
  final double? trimPathStart;
  final double? trimPathEnd;
  final double? trimPathOffset;
  */

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
      ].anyNotNull();

  VectorPath copyWith({
    List<PathNode>? pathData,
    String? id,
    Gradient? fill,
    double? fillAlpha,
    Gradient? stroke,
    double? strokeAlpha,
    double? strokeLineWidth,
    StrokeCap? strokeLineCap,
    StrokeJoin? strokeLineJoin,
    double? strokeLineMiter,
    PathFillType? pathFillType,
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
    );
  }
}

class VectorPathBuilder
    extends VectorNodeBuilder<VectorPath, VectorPathBuilder> {
  VectorPathBuilder(this._pathData);

  final List<PathNode> _pathData;

  @override
  VectorPath build() {
    return VectorPath._init(
      _pathData,
      id: id_,
      fill: fill_,
      fillAlpha: fillAlpha_,
      stroke: stroke_,
      strokeAlpha: strokeAlpha_,
      strokeLineWidth: strokeLineWidth_,
      strokeLineCap: strokeLineCap_,
      strokeLineJoin: strokeLineJoin_,
      strokeLineMiter: strokeLineMiter_,
      pathFillType: pathFillType_,
    );
  }
}

enum PathDataCommand {
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
  close,
}

class PathNode {
  // TODO: add named constructors for each command?
  const PathNode(this.command, this.arguments);

  final PathDataCommand command;
  final List<dynamic> arguments;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PathNode &&
          runtimeType == other.runtimeType &&
          command == other.command &&
          ListEquality().equals(arguments, other.arguments);

  @override
  int get hashCode => command.hashCode ^ arguments.hashCode;
}
