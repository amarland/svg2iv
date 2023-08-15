import 'package:collection/collection.dart';
import 'package:xml/xml.dart';

import '../../models.dart';
import '../extensions.dart';
import '../file_parser.dart';
import '../util/android_resources.dart';
import '../util/path_building_helpers.dart';

enum _Shape { rectangle, oval, line, ring }

ImageVector parseShapeDrawableElement(
  XmlElement rootElement, {
  String? sourceName,
}) {
  final sizeElement = rootElement.getElement('size');
  final width = sizeElement?.getAndroidNSAttribute<Dimension>('width')?.value;
  final height = sizeElement?.getAndroidNSAttribute<Dimension>('height')?.value;
  if (width == null || height == null) {
    throw ParserException(
      'This tool does not support converting gradient drawables'
      ' without an explicit size (both width and height).',
    );
  }
  final imageVectorBuilder = ImageVectorBuilder(width, height);
  sourceName?.let(imageVectorBuilder.name);
  final shape = rootElement
          .getAndroidNSAttribute<String>('shape')
          ?.let(_Shape.values.byName) ??
      _Shape.rectangle;
  final VectorPathBuilder vectorPathBuilder;
  final bounds = Rect(0.0, 0.0, width, height);
  switch (shape) {
    case _Shape.oval:
      vectorPathBuilder = _buildOvalPathGeometry(rootElement, bounds);
      break;
    case _Shape.line:
      vectorPathBuilder = _buildLinePathGeometry(rootElement, bounds);
      break;
    case _Shape.ring:
      vectorPathBuilder = _buildRingPathGeometry(rootElement, bounds);
      break;
    default:
      vectorPathBuilder = _buildRectanglePathGeometry(rootElement, bounds);
      break;
  }
  _parseFill(rootElement, bounds)?.let(vectorPathBuilder.fill);
  _parseStroke(rootElement)?.let((stroke) {
    final (brush, width) = stroke;
    vectorPathBuilder.stroke(brush);
    vectorPathBuilder.strokeLineWidth(width);
  });
  return imageVectorBuilder.addNode(vectorPathBuilder.build()).build();
}

VectorPathBuilder _buildRectanglePathGeometry(
  XmlElement rootElement,
  Rect bounds,
) {
  final cornersElement = rootElement.getElement('corners');
  final List<double>? radii;
  if (cornersElement == null) {
    radii = null;
  } else {
    final radius =
        cornersElement.getAndroidNSAttribute<Dimension>('radius')?.value ?? 0.0;
    radii = List.filled(8, radius, growable: false);
    [
      'topLeftRadius',
      'topRightRadius',
      'bottomRightRadius',
      'bottomLeftRadius',
    ].forEachIndexed((index, attributeName) {
      final radius =
          cornersElement.getAndroidNSAttribute<Dimension>(attributeName)?.value;
      if (radius != null && radius != radii![index]) {
        radii[index] = radius;
        radii[index + 1] = radius;
      }
    });
  }
  return VectorPathBuilder(
    obtainPathNodesForRectangle(bounds: bounds, radii: radii),
  );
}

VectorPathBuilder _buildOvalPathGeometry(
  XmlElement rootElement,
  Rect bounds,
) {
  final rx = bounds.width / 2.0;
  final ry = bounds.height / 2.0;
  return VectorPathBuilder(
    obtainPathNodesForEllipse(
      cx: bounds.left + rx,
      cy: bounds.top + ry,
      rx: rx,
      ry: ry,
    ),
  );
}

VectorPathBuilder _buildLinePathGeometry(
  XmlElement rootElement,
  Rect bounds,
) {
  return VectorPathBuilder([
    MoveToNode(bounds.left, bounds.top),
    LineToNode(bounds.right, bounds.bottom),
  ]);
}

VectorPathBuilder _buildRingPathGeometry(
  XmlElement rootElement,
  Rect bounds,
) {
  final innerRadiusRatio =
      rootElement.getAndroidNSAttribute<double>('innerRadiusRatio') ?? 9.0;
  final innerRadius =
      rootElement.getAndroidNSAttribute<Dimension>('innerRadius')?.value ??
          bounds.width / innerRadiusRatio;
  final thicknessRatio =
      rootElement.getAndroidNSAttribute<double>('thicknessRatio') ?? 3.0;
  final thickness =
      rootElement.getAndroidNSAttribute<Dimension>('thickness')?.value ??
          bounds.width / thicknessRatio;
  final rx = bounds.width / 2.0;
  final ry = bounds.height / 2.0;
  final cx = bounds.left + rx;
  final cy = bounds.top + ry;
  final innerBounds = Rect.fromRect(bounds);
  innerBounds.inset(cx - innerRadius, cy - innerRadius);
  final irx = innerBounds.width / 2.0;
  final iry = innerBounds.height / 2.0;
  bounds = Rect.fromRect(innerBounds);
  bounds.inset(-thickness, -thickness);
  final pathData = obtainPathNodesForEllipse(cx: cx, cy: cy, rx: rx, ry: ry) +
      obtainPathNodesForEllipse(cx: cx, cy: cy, rx: irx, ry: iry);
  return VectorPathBuilder(pathData).pathFillType(PathFillType.evenOdd);
}

Brush? _parseFill(XmlElement rootElement, Rect bounds) {
  final singleColor = rootElement
      .getElement('solid')
      ?.getAndroidNSAttribute<SolidColor>('color');
  final gradientElement = rootElement.getElement('gradient');
  if (singleColor != null) {
    if (gradientElement != null) {
      throw ParserException(
        'This gradient drawable defines both a solid color and a gradient.',
      );
    }
    return singleColor;
  }
  return gradientElement?.let((element) => parseGradient(element, bounds));
}

(Brush, double)? _parseStroke(XmlElement rootElement) {
  final strokeElement = rootElement.getElement('stroke');
  final color = strokeElement?.getAndroidNSAttribute<SolidColor>('color');
  final width = strokeElement?.getAndroidNSAttribute<Dimension>('width')?.value;
  if (color != null && width != null) {
    return (color, width);
  }
  return null;
}
