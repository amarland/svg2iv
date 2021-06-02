import 'package:svg2iv_common/extensions.dart';
import 'package:svg2iv_common/gradient.dart';
import 'package:svg2iv_common/image_vector.dart';
import 'package:svg2iv_common/vector_group.dart';
import 'package:svg2iv_common/vector_node.dart';
import 'package:svg2iv_common/vector_path.dart';
import 'package:svg2iv/protobuf/image_vector.pb.dart' as $pb;

$pb.ImageVectorCollection imageVectorIterableAsProtobuf(
  Iterable<ImageVector?> imageVectors,
) {
  return $pb.ImageVectorCollection(
    nullableImageVectors: imageVectors.map(
      (v) => v != null
          ? $pb.NullableImageVector(value: imageVectorAsProtobuf(v))
          : $pb.NullableImageVector(nothing: $pb.Null.NOTHING),
    ),
  );
}

$pb.ImageVector imageVectorAsProtobuf(ImageVector imageVector) {
  final tintBlendMode =
      imageVector.tintBlendMode ?? ImageVector.defaultTintBlendMode;
  return $pb.ImageVector(
    nodes: _mapVectorNodes(imageVector.nodes),
    name: imageVector.name,
    viewportWidth: imageVector.viewportWidth,
    viewportHeight: imageVector.viewportHeight,
    width: imageVector.width,
    height: imageVector.height,
    tintColor: imageVector.tintColor,
    tintBlendMode: $pb.BlendMode.values[tintBlendMode.index],
  );
}

Iterable<$pb.VectorNode> _mapVectorNodes(Iterable<VectorNode> nodes) =>
    nodes.map((node) {
      final mappedGroup = node is VectorGroup ? _mapVectorGroup(node) : null;
      final mappedPath = node is VectorPath ? _mapVectorPath(node) : null;
      return $pb.VectorNode(group: mappedGroup, path: mappedPath);
    });

$pb.VectorGroup _mapVectorGroup(VectorGroup group) {
  return $pb.VectorGroup(
    nodes: _mapVectorNodes(group.nodes),
    id: group.id,
    rotation: group.rotation?.angle,
    pivotX: group.rotation?.pivotX,
    pivotY: group.rotation?.pivotY,
    scaleX: group.scale?.x ?? VectorGroup.defaultScaleX,
    scaleY: group.scale?.y ?? VectorGroup.defaultScaleY,
    translationX: group.translation?.x,
    translationY: group.translation?.y,
    clipPathData: group.clipPathData?.map(_mapPathNode),
  );
}

$pb.VectorPath _mapVectorPath(VectorPath path) {
  final strokeLineCap = path.strokeLineCap ?? VectorPath.defaultStrokeLineCap;
  final strokeLineJoin =
      path.strokeLineJoin ?? VectorPath.defaultStrokeLineJoin;
  final pathFillType = path.pathFillType ?? VectorPath.defaultPathFillType;
  return $pb.VectorPath(
    pathNodes: path.pathData.map(_mapPathNode),
    id: path.id,
    fill: _mapGradient(path.fill ?? VectorPath.defaultFill),
    fillAlpha: path.fillAlpha ?? VectorPath.defaultFillAlpha,
    stroke: _mapGradient(path.stroke),
    strokeAlpha: path.strokeAlpha ?? VectorPath.defaultStrokeAlpha,
    strokeLineWidth: path.strokeLineWidth,
    strokeLineCap: $pb.VectorPath_StrokeCap.values[strokeLineCap.index],
    strokeLineJoin: $pb.VectorPath_StrokeJoin.values[strokeLineJoin.index],
    strokeLineMiter: path.strokeLineMiter ?? VectorPath.defaultStrokeLineMiter,
    fillType: $pb.VectorPath_FillType.values[pathFillType.index],
    trimPathStart: path.trimPathStart ?? VectorPath.defaultTrimPathStart,
    trimPathEnd: path.trimPathEnd ?? VectorPath.defaultTrimPathEnd,
    trimPathOffset: path.trimPathOffset ?? VectorPath.defaultTrimPathOffset,
  );
}

$pb.PathNode _mapPathNode(PathNode pathNode) {
  return $pb.PathNode(
    command: $pb.PathNode_Command.values[pathNode.command.index],
    arguments: pathNode.arguments.map((arg) {
      if (arg is bool) {
        return $pb.PathNode_Argument(flag: arg);
      } else {
        // calling `toDouble` seems to fix a cast issue from `_Smi`, somehow
        return $pb.PathNode_Argument(coordinate: arg.toDouble());
      }
    }),
  );
}

$pb.Brush? _mapGradient(Gradient? gradient) {
  if (gradient == null) return null;
  final tileMode = gradient.tileMode?.let(
    (it) => $pb.Gradient_TileMode.values[it.index],
  );
  final colors = gradient.colors;
  if (colors.length == 1 || colors.every((c) => c == colors[0])) {
    return $pb.Brush(solidColor: colors[0]);
  }
  if (gradient is LinearGradient) {
    return $pb.Brush(
      linearGradient: $pb.Gradient(
        colors: colors,
        stops: gradient.stops,
        startX: gradient.startX,
        startY: gradient.startY,
        endX: gradient.endX,
        endY: gradient.endY,
        tileMode: tileMode,
      ),
    );
  }
  if (gradient is RadialGradient) {
    return $pb.Brush(
      radialGradient: $pb.Gradient(
        colors: colors,
        stops: gradient.stops,
        centerX: gradient.centerX,
        centerY: gradient.centerY,
        radius: gradient.radius,
        tileMode: tileMode,
      ),
    );
  }
}
