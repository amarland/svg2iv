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
  final bounds = Rect(0.0, 0.0, width, height);
  final vectorPathBuilder = switch (shape) {
    _Shape.line => _buildLinePathGeometry(rootElement, bounds),
    _Shape.oval => _buildOvalPathGeometry(rootElement, bounds),
    _Shape.rectangle => _buildRectanglePathGeometry(rootElement, bounds),
    _Shape.ring => _buildRingPathGeometry(rootElement, bounds),
  };
  _parseFill(rootElement, bounds)?.let(vectorPathBuilder.fill);
  _parseStroke(rootElement)?.let((stroke) {
    final (solidColor, width) = stroke;
    vectorPathBuilder.stroke(solidColor);
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
  final cx = bounds.left + bounds.width / 2.0;
  final cy = bounds.top + bounds.height / 2.0;
  final innerBounds = Rect.fromRect(bounds);
  innerBounds.inset(cx - innerRadius, cy - innerRadius);
  bounds = Rect.fromRect(innerBounds);
  bounds.inset(-thickness, -thickness);
  final pathData = obtainPathNodesForEllipse(
        cx: cx,
        cy: cy,
        rx: bounds.width / 2.0,
        ry: bounds.height / 2.0,
      ) +
      obtainPathNodesForEllipse(
        cx: cx,
        cy: cy,
        rx: innerBounds.width / 2.0,
        ry: innerBounds.height / 2.0,
      );
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

(SolidColor, double)? _parseStroke(XmlElement rootElement) {
  final strokeElement = rootElement.getElement('stroke');
  final color = strokeElement?.getAndroidNSAttribute<SolidColor>('color');
  final width = strokeElement?.getAndroidNSAttribute<Dimension>('width')?.value;
  if (color != null && width != null) {
    return (color, width);
  }
  return null;
}
