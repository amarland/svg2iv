import 'package:svg2iv/extensions.dart';
import 'package:svg2iv/model/gradient.dart';
import 'package:svg2iv/model/image_vector.dart';
import 'package:svg2iv/model/vector_group.dart';
import 'package:svg2iv/model/vector_node.dart';
import 'package:svg2iv/model/vector_path.dart';
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
  return $pb.ImageVector(
    nodes: _mapVectorNodes(imageVector.nodes),
    name: imageVector.name,
    viewportWidth: imageVector.viewportWidth,
    viewportHeight: imageVector.viewportHeight,
    width: imageVector.width,
    height: imageVector.height,
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
    scaleX: group.scale?.x ?? 1.0,
    scaleY: group.scale?.y ?? 1.0,
    translationX: group.translation?.x,
    translationY: group.translation?.y,
    clipPathData: group.clipPathData?.map(_mapPathNode),
  );
}

$pb.VectorPath _mapVectorPath(VectorPath path) {
  final strokeLineCap = path.strokeLineCap;
  final strokeLineJoin = path.strokeLineJoin;
  final pathFillType = path.pathFillType;
  return $pb.VectorPath(
    pathNodes: path.pathData.map(_mapPathNode),
    id: path.id,
    fill: _mapGradient(path.fill),
    fillAlpha: path.fillAlpha ?? 1.0,
    stroke: _mapGradient(path.stroke),
    strokeAlpha: path.strokeAlpha ?? 1.0,
    strokeLineWidth: path.strokeLineWidth,
    strokeLineCap: strokeLineCap != null
        ? $pb.VectorPath_StrokeCap.values[strokeLineCap.index]
        : $pb.VectorPath_StrokeCap.CAP_BUTT,
    strokeLineJoin: strokeLineJoin != null
        ? $pb.VectorPath_StrokeJoin.values[strokeLineJoin.index]
        : $pb.VectorPath_StrokeJoin.JOIN_MITER,
    strokeLineMiter: path.strokeLineMiter ?? 4.0,
    fillType: pathFillType != null
        ? $pb.VectorPath_FillType.values[pathFillType.index]
        : $pb.VectorPath_FillType.NON_ZERO,
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
  } else if (gradient is RadialGradient) {
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
