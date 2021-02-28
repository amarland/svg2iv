import 'package:svg2iv/extensions.dart';
import 'package:svg2iv/model/gradient.dart';
import 'package:svg2iv/model/image_vector.dart';
import 'package:svg2iv/model/vector_group.dart';
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
    group: _mapVectorGroup(imageVector.group),
    name: imageVector.name,
    viewportWidth: imageVector.viewportWidth,
    viewportHeight: imageVector.viewportHeight,
    width: imageVector.width,
    height: imageVector.height,
  );
}

$pb.VectorGroup _mapVectorGroup(VectorGroup group) {
  return $pb.VectorGroup(
    nodes: group.nodes.map((node) {
      final mappedGroup = node is VectorGroup ? _mapVectorGroup(node) : null;
      final mappedPath = node is VectorPath ? _mapVectorPath(node) : null;
      return $pb.VectorNode(group: mappedGroup, path: mappedPath);
    }),
    id: group.id,
    rotation: group.rotation?.angle,
    pivotX: group.rotation?.pivotX,
    pivotY: group.rotation?.pivotY,
    scaleX: group.scale?.x,
    scaleY: group.scale?.y,
    translationX: group.translation?.x,
    translationY: group.translation?.y,
    clipPathData: group.clipPathData?.map(_mapPathNode),
  );
}

$pb.VectorPath _mapVectorPath(VectorPath path) {
  return $pb.VectorPath(
    pathNodes: path.pathData.map(_mapPathNode),
    id: path.id,
    fill: _mapGradient(path.fill),
    fillAlpha: path.fillAlpha,
    stroke: _mapGradient(path.stroke),
    strokeAlpha: path.strokeAlpha,
    strokeLineWidth: path.strokeLineWidth,
    strokeLineCap: path.strokeLineCap?.let(
      (it) => $pb.VectorPath_StrokeCap.values[it.index],
    ),
    strokeLineJoin: path.strokeLineJoin?.let(
      (it) => $pb.VectorPath_StrokeJoin.values[it.index],
    ),
    strokeLineMiter: path.strokeLineMiter,
    fillType: path.pathFillType?.let(
      (it) => $pb.VectorPath_FillType.values[it.index],
    ),
  );
}

$pb.PathNode _mapPathNode(PathNode pathNode) {
  return $pb.PathNode(
    command: $pb.PathNode_Command.values[pathNode.command.index],
    arguments: pathNode.arguments.map((arg) {
      if (arg is bool) {
        return $pb.PathNode_Argument(flag: arg);
      } else {
        return $pb.PathNode_Argument(coordinate: arg);
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
