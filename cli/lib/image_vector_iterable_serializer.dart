import 'package:cbor/cbor.dart';
import 'package:svg2iv_common/utils.dart';
import 'package:svg2iv_common/models.dart';

extension ImageVectorIterableToCborSerialization on Iterable<ImageVector?> {
  List<int> toCbor() {
    final imageVectors = map((imageVector) =>
    imageVector != null ? _mapImageVector(imageVector) : null);
    return CborSimpleEncoder().convert(imageVectors);
  }
}

Map<String, dynamic> _mapImageVector(ImageVector imageVector) {
  return {
    'vectorName': imageVector.name,
    'viewportWidth': imageVector.viewportWidth,
    'viewportHeight': imageVector.viewportHeight,
    'width': imageVector.width,
    'height': imageVector.height,
    'tintColor': imageVector.tintColor,
    'tintBlendMode': imageVector.tintBlendMode?.index,
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
    'strokeLineCap': strokeLineCap?.index,
    'strokeLineJoin': strokeLineJoin?.index,
    'strokeLineMiter': path.strokeLineMiter,
    'fillType': pathFillType?.index,
    'trimPathStart': path.trimPathStart,
    'trimPathEnd': path.trimPathEnd,
    'trimPathOffset': path.trimPathOffset,
    'pathNodes': path.pathData.map(_mapPathNode),
  }..removeWhereValueIsNull();
}

Map<String, dynamic> _mapPathNode(PathNode pathNode) {
  return {
    'command': pathNode.command.index,
    'arguments': pathNode.arguments.map<double>((value) {
      if (value is double) return value;
      if (value is bool) return value ? 1.0 : 0.0;
      throw 'Argument $value for path node $pathNode'
          ' is neither a double nor a boolean.';
    }),
  };
}

// returns either a Map<String, dynamic> (gradient) or a color int (solid color)
dynamic _mapGradient(Brush? paint) {
  if (paint == null) {
    return null;
  }
  if (paint is SolidColor) {
    return paint.colorInt;
  }
  paint as Gradient;
  final Map<String, double> typeSpecificAttributes;
  final isLinear = paint is LinearGradient;
  if (isLinear) {
    typeSpecificAttributes = {
      'startX': paint.startX,
      'startY': paint.startY,
      'endX': paint.endX,
      'endY': paint.endY,
    };
  } else {
    paint as RadialGradient;
    typeSpecificAttributes = {
      'centerX': paint.centerX,
      'centerY': paint.centerY,
      'radius': paint.radius,
    };
  }
  return {
    'isLinear': isLinear,
    'colors': paint.colors,
    'stops': paint.stops,
    ...typeSpecificAttributes,
    'tileMode': paint.tileMode?.index,
  }..removeWhereValueIsNull();
}
