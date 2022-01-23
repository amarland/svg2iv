import 'dart:ui';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:svg2iv_common/extensions.dart';
import 'package:svg2iv_common/model/image_vector.dart';
import 'package:svg2iv_common/model/vector_group.dart';
import 'package:svg2iv_common/model/vector_node.dart';
import 'package:svg2iv_common/model/vector_path.dart';
import 'package:svg2iv_gui/util/vector_path_command_interpreter.dart';

import '../util/extensions.dart';

Picture imageVectorToPicture(ImageVector imageVector, Size size) {
  return DrawableRoot(
    imageVector.name,
    DrawableViewport(
      size,
      Size(imageVector.viewportWidth, imageVector.viewportHeight),
    ),
    _mapVectorNodes(imageVector.nodes),
    DrawableDefinitionServer(),
    const DrawableStyle(),
  ).toPicture(size: size);
}

List<Drawable> _mapVectorNodes(List<VectorNode> nodes) {
  return nodes
      .map((node) => node is VectorGroup
          ? _mapVectorGroup(node)
          : _mapVectorPath(node as VectorPath))
      .toList(growable: false);
}

Drawable _mapVectorGroup(VectorGroup vectorGroup) {
  return DrawableGroup(
    vectorGroup.id,
    _mapVectorNodes(vectorGroup.nodes),
    const DrawableStyle(),
    transform: vectorGroup.getTransform(),
  );
}

Drawable _mapVectorPath(VectorPath vectorPath) {
  return DrawableShape(
    vectorPath.id,
    // parseSvgPathData(vectorPath.pathData.toSvgPathDataString()),
    Path().also((path) => interpretPathCommands(vectorPath.pathData, path)),
    DrawableStyle(
      fill: _obtainDrawablePaintForStyle(vectorPath, PaintingStyle.fill),
      pathFillType: vectorPath.pathFillType?.toFlutterPathFillType(),
      stroke: _obtainDrawablePaintForStyle(vectorPath, PaintingStyle.stroke),
    ),
  );
}

DrawablePaint? _obtainDrawablePaintForStyle(
  VectorPath path,
  PaintingStyle style,
) {
  final isStroke = style == PaintingStyle.stroke;
  final paint = isStroke
      ? path.stroke?.asPaint()
      : path.fill?.asPaint() ?? Paint(); // no fill => black by default
  if (paint == null) return null;
  return DrawablePaint(
    style,
    color: paint.color,
    shader: paint.shader,
    strokeCap: isStroke ? path.strokeLineCap.toFlutterStrokeCap() : null,
    strokeJoin: isStroke ? path.strokeLineJoin.toFlutterStrokeJoin() : null,
    strokeMiterLimit: isStroke
        ? path.strokeLineMiter ?? VectorPath.defaultStrokeLineMiter
        : null,
    strokeWidth: isStroke
        ? path.strokeLineWidth ?? VectorPath.defaultStrokeLineWidth
        : null,
  );
}
