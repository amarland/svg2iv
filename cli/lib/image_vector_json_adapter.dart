import 'dart:convert';

import 'package:svg2iv_common/extensions.dart';
import 'package:svg2iv_common/model/gradient.dart';
import 'package:svg2iv_common/model/image_vector.dart';
import 'package:svg2iv_common/model/vector_group.dart';
import 'package:svg2iv_common/model/vector_node.dart';
import 'package:svg2iv_common/model/vector_path.dart';
import 'package:svg2iv_common/color_utils.dart';

extension ImageVectorIterableToJsonConversion on Iterable<ImageVector?> {
  List<int> toJson() {
    final imageVectors = map((imageVector) => imageVector != null
        ? _formatDoubles(_mapImageVector(imageVector))
        : null);
    return JsonUtf8Encoder(
      null,
      (o) {
        return o is Iterable
            ? o.toNonGrowableList()
            : throw JsonUnsupportedObjectError(o);
      },
    ).convert(imageVectors);
  }
}

Map<String, dynamic> _mapImageVector(ImageVector imageVector) {
  return {
    'vectorName': imageVector.name,
    'viewportWidth': imageVector.viewportWidth,
    'viewportHeight': imageVector.viewportHeight,
    'width': imageVector.width,
    'height': imageVector.height,
    'tintColor': imageVector.tintColor?.let(colorIntToArgb),
    'tintBlendMode': imageVector.tintBlendMode?.name,
    'nodes': _mapVectorNodes(imageVector.nodes),
  }..removeWhereValueIsNull();
}

Iterable<Map<String, dynamic>> _mapVectorNodes(Iterable<VectorNode> nodes) =>
    nodes.map((node) => node is VectorGroup
        ? _mapVectorGroup(node)
        : _mapVectorPath(node as VectorPath));

Map<String, dynamic> _mapVectorGroup(VectorGroup group) {
  return {
    'groupName': group.id,
    'rotation': group.rotation?.angle,
    'pivotX': group.rotation?.pivotX,
    'pivotY': group.rotation?.pivotY,
    'scaleX': group.scale?.x,
    'scaleY': group.scale?.y,
    'translationX': group.translation?.x,
    'translationY': group.translation?.y,
    'clipPathData': group.clipPathData?.map(_mapPathNode),
    'nodes': _mapVectorNodes(group.nodes),
  }..removeWhereValueIsNull();
}

Map<String, dynamic> _mapVectorPath(VectorPath path) {
  final strokeLineCap = path.strokeLineCap;
  final strokeLineJoin = path.strokeLineJoin;
  final pathFillType = path.pathFillType;
  return {
    'pathName': path.id,
    'fill': _mapGradient(path.fill),
    'fillAlpha': path.fillAlpha,
    'stroke': _mapGradient(path.stroke),
    'strokeAlpha': path.strokeAlpha,
    'strokeLineWidth': path.strokeLineWidth,
    'strokeLineCap': strokeLineCap?.name,
    'strokeLineJoin': strokeLineJoin?.name,
    'strokeLineMiter': path.strokeLineMiter,
    'fillType': pathFillType?.name,
    'trimPathStart': path.trimPathStart,
    'trimPathEnd': path.trimPathEnd,
    'trimPathOffset': path.trimPathOffset,
    'pathNodes': path.pathData.map(_mapPathNode),
  }..removeWhereValueIsNull();
}

Map<String, dynamic> _mapPathNode(PathNode pathNode) {
  return {
    'command': pathNode.command.name,
    'arguments': pathNode.arguments,
  };
}

// returns either a Map<String, dynamic> (gradient)
// or an array of RGB values (solid color)
dynamic _mapGradient(Gradient? gradient) {
  if (gradient == null) return null;

  if (gradient.colors.length == 1) {
    return colorIntToArgb(gradient.colors[0]);
  }
  final Map<String, double> typeSpecificAttributes;
  final isLinear = gradient is LinearGradient;
  if (isLinear) {
    typeSpecificAttributes = {
      'startX': gradient.startX,
      'startY': gradient.startY,
      'endX': gradient.endX,
      'endY': gradient.endY,
    };
  } else {
    gradient as RadialGradient;
    typeSpecificAttributes = {
      'centerX': gradient.centerX,
      'centerY': gradient.centerY,
      'radius': gradient.radius,
    };
  }
  return {
    'type': isLinear ? 'linear' : 'radial',
    'colors': gradient.colors.map(colorIntToArgb),
    'stops': gradient.stops,
    ...typeSpecificAttributes,
    'tileMode': gradient.tileMode?.name,
  }..removeWhereValueIsNull();
}

List<int> _mapColor(int value) {
  return [
    (0xFF000000 & value) >> 24,
    (0x00FF0000 & value) >> 16,
    (0x0000ff00 & value) >> 8,
    0x000000FF & value,
  ];
}

void _formatDoubles(Map<String, dynamic> map) {
  for (final entry in map.entries) {
    final value = entry.value;
    if (value is double) {
      map[entry.key] = value.toStringWithMaxDecimals(4);
    } else if (value is Map<String, dynamic>) {
      _formatDoubles(value);
    }
  }
}
