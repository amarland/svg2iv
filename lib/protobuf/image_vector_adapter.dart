// @dart=2.9

import 'package:svg2va/model/gradient.dart';
import 'package:svg2va/model/image_vector.dart';
import 'package:svg2va/model/vector_group.dart';
import 'package:svg2va/model/vector_path.dart';
import 'package:svg2va/protobuf/image_vector.pb.dart' as $pb;

$pb.ImageVectorCollection imageVectorIterableAsProtobuf(
  Iterable<ImageVector> imageVectors,
) {
  return $pb.ImageVectorCollection(
    nullableImageVectors: imageVectors.map(
      (v) => v != null ? imageVectorAsProtobuf(v) : $pb.NullableImageVector(),
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
    rotation: group.rotation.angle,
    pivotX: group.rotation.pivotX,
    pivotY: group.rotation.pivotY,
    scaleX: group.scale.x,
    scaleY: group.scale.y,
    translationX: group.translation.x,
    translationY: group.translation.y,
    clipPathData: group.clipPathData.map(_mapPathNode),
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
    strokeLineCap: $pb.VectorPath_StrokeCap.values[path.strokeLineCap.index],
    strokeLineJoin: $pb.VectorPath_StrokeJoin.values[path.strokeLineJoin.index],
    strokeLineMiter: path.strokeLineMiter,
    fillType: $pb.VectorPath_FillType.values[path.pathFillType.index],
  );
}

$pb.PathNode _mapPathNode(PathNode pathNode) {
  return $pb.PathNode(
    command: $pb.PathNode_Command.values[pathNode.command.index],
    arguments: pathNode.arguments.map((arg) {
      if (arg is bool) {
        return $pb.PathNode_Argument(flag: arg);
      } else if (arg is double) {
        return $pb.PathNode_Argument(coordinate: arg);
      } else {
        return null;
      }
    }),
  );
}

$pb.Brush _mapGradient(Gradient gradient) {
  final tileMode = $pb.Gradient_TileMode.values[gradient.tileMode.index];
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
  return null;
}
