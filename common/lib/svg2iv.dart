import 'package:collection/collection.dart';
import 'package:svg2iv_common/path_building_helpers.dart';
import 'package:xml/xml.dart';

import 'extensions.dart';
import 'file_parser.dart';
import 'model/gradient.dart';
import 'model/image_vector.dart';
import 'model/transformations.dart';
import 'model/vector_group.dart';
import 'model/vector_node.dart';
import 'model/vector_path.dart';
import 'path_data_parser.dart';
import 'svg_preprocessor.dart';

final _definitionSeparatorPattern = RegExp(r'[,\s]\s*');

final _definitions = <String, dynamic>{};

ImageVector parseSvgElement(XmlElement rootElement) {
  preprocessSvg(rootElement);
  final viewBox = rootElement
      .getAttribute('viewBox')
      ?.split(_definitionSeparatorPattern)
      .map(double.tryParse)
      .toList()
      .takeIf(
        (viewBox) => viewBox.length == 4 && viewBox.sublist(2).everyNotNull(),
      );
  final widthAsString = rootElement.getAttribute('width');
  final heightAsString = rootElement.getAttribute('height');
  double? viewportWidth, viewportHeight;
  double? width, height;
  double? minX, minY;
  if (viewBox != null) {
    minX = viewBox[0];
    minY = viewBox[1];
    viewportWidth = viewBox[2]!;
    viewportHeight = viewBox[3]!;
  }
  minX ??= 0.0;
  minY ??= 0.0;
  if (!widthAsString.isNullOrEmpty &&
      !widthAsString!.endsWith('%') &&
      !heightAsString.isNullOrEmpty &&
      !heightAsString!.endsWith('%')) {
    width = widthAsString.toDouble();
    height = heightAsString.toDouble();
  }
  viewportWidth ??= width;
  viewportHeight ??= height;
  if (viewportWidth == null || viewportHeight == null) {
    throw FileParserException(
      'The size of the viewport could not be determined.',
    );
  }
  final builder = ImageVectorBuilder(viewportWidth, viewportHeight);
  rootElement.getAttribute('id')?.let(builder.name);
  if (width == null && widthAsString != null) {
    width = _parseLength(widthAsString, baseForPercentage: viewportWidth);
  }
  if (height == null && heightAsString != null) {
    height = _parseLength(heightAsString, baseForPercentage: viewportHeight);
  }
  width?.let(builder.width);
  height?.let(builder.height);
  // possible translation resulting from having non-zero min coordinates
  final rootGroupTranslation =
      minX != 0.0 || minY != 0.0 ? Translation(-minX, -minY) : null;
  final nodes = _extractNodesOfInterest(rootElement);
  if (rootGroupTranslation != null) {
    final singleNode = nodes.singleOrNull;
    if (singleNode is VectorGroup) {
      final existingTranslation = singleNode.translation;
      builder.addNode(
        singleNode.copyWith(
            translation: existingTranslation != null
                ? existingTranslation + rootGroupTranslation
                : rootGroupTranslation),
      );
    } else {
      final rootGroupBuilder = VectorGroupBuilder();
      nodes.forEach(rootGroupBuilder.addNode);
      final transformations = TransformationsBuilder()
          .translate(
            x: rootGroupTranslation.x,
            y: rootGroupTranslation.y,
          )
          .build()!;
      rootGroupBuilder.transformations(transformations);
      builder.addNode(rootGroupBuilder.build());
    }
  } else {
    builder.addNodes(nodes);
  }
  _definitions.clear();
  return builder.build();
}

Iterable<VectorNode> _extractNodesOfInterest(XmlElement rootElement) sync* {
  for (final element in rootElement.children.whereType<XmlElement>().where(
    (element) {
      final displayAttribute = element.getAttribute('display');
      return displayAttribute == null || displayAttribute != 'none';
    },
  )) {
    final nodes = <VectorNode?>[];
    switch (element.name.local) {
      case 'defs':
        for (final node in _extractNodesOfInterest(element)
            .where((n) => !n.id.isNullOrEmpty)) {
          _definitions[node.id!] = node;
        }
        break;
      case 'g':
        nodes.add(_parseGroupElement(element));
        break;
      case 'path':
        nodes.add(_parsePathElement(element));
        break;
      case 'line':
        nodes.add(_parseLineElement(element));
        break;
      case 'polyline':
      case 'polygon':
        nodes.add(_parsePolyShapeElement(element));
        break;
      case 'rect':
        nodes.add(_parseRectElement(element));
        break;
      case 'circle':
      case 'ellipse':
        nodes.add(_parseEllipseElement(element));
        break;
      case 'clipPath':
        final id = element.getAttribute('id');
        if (!id.isNullOrEmpty) {
          final paths = <VectorPath>[];
          // clipPath elements with paths referencing other clipPath elements
          // have been nested in "reverse" order during preprocessing
          for (XmlElement? e = element;
              e != null;
              e = e.findElements('clipPath').singleOrNull) {
            _extractNodesOfInterest(e)
                .whereType<VectorPath>()
                .singleOrNull
                ?.let((path) => paths.add(path));
          }
          if (paths.isNotEmpty) {
            _definitions[id!] = paths;
          }
        }
        // yields nothing
        break;
      case 'linearGradient':
      case 'radialGradient':
        final id = element.getAttribute('id');
        if (!id.isNullOrEmpty) {
          final gradient = _parseGradient(element);
          _definitions[id!] = gradient;
        }
        // yields nothing
        break;
    }
    for (final node in nodes.whereNotNull()) {
      yield node;
    }
  }
}

VectorGroup _parseGroupElement(XmlElement groupElement) {
  final builder = VectorGroupBuilder();
  _parseTransformations(groupElement)?.let((t) => builder.transformations(t));
  for (final childNode in _extractNodesOfInterest(groupElement)) {
    builder.addNode(childNode);
  }
  _fillPresentationAttributes(groupElement, builder);
  return _handleClipPathAttribute(groupElement, builder) ?? builder.build();
}

Transformations? _parseTransformations(XmlElement element) {
  final transformAttribute = element.getAttribute('transform');
  if (transformAttribute == null) return null;
  final builder = TransformationsBuilder();
  final definitions = transformAttribute.split(RegExp(r'\)\s*')).toList()
    ..removeLast(); // the last element is an empty string
  for (final definition in definitions) {
    final nameAndValues =
        definition.split(RegExp(r'\s*\(\s*')).map((s) => s.trim()).toList();
    final name = nameAndValues[0];
    final values = nameAndValues[1];
    if (nameAndValues.length < 2 || values.isEmpty) {
      break;
    }
    final parsedValues = values
        .split(_definitionSeparatorPattern)
        .map(double.tryParse)
        .whereNotNull()
        .toList();
    switch (name) {
      case 'translate':
        final count = parsedValues.length;
        if (parsedValues.isNotEmpty && count <= 2) {
          builder.translate(
            x: parsedValues[0],
            y: count == 2 ? parsedValues[1] : null,
          );
        }
        break;
      case 'scale':
        final count = parsedValues.length;
        if (parsedValues.isNotEmpty && count <= 2) {
          builder.scale(
            x: parsedValues[0],
            y: count == 2 ? parsedValues[1] : null,
          );
        }
        break;
      case 'rotate':
        final count = parsedValues.length;
        if (parsedValues.isNotEmpty && count <= 3) {
          builder.rotate(
            angleInDegrees: parsedValues[0],
            pivotX: count >= 2 ? parsedValues[1] : null,
            pivotY: count == 3 ? parsedValues[2] : null,
          );
        }
        break;
      default:
        if (name.startsWith('skew')) {
          final value = parsedValues.singleOrNull;
          if (value != null) {
            switch (name[name.length - 1]) {
              case 'X':
                builder.skewX(value);
                break;
              case 'Y':
                builder.skewY(value);
                break;
            }
          }
        }
        break;
    }
  }
  // result of preprocessing
  final customAttributes = element.attributes
      .where((attrs) =>
          attrs.name.local.startsWith(useElementCustomAttributePrefix))
      .associate(
        (attr) => attr.name.local,
        (attr) => attr.value.toDouble(),
      );
  final offsetX = customAttributes['x'];
  final offsetY = customAttributes['y'];
  if (offsetX != null && offsetY != null) {
    builder.translate(x: offsetX, y: offsetY);
  }
  return builder.build();
}

VectorNode? _parsePathElement(XmlElement pathElement) {
  final transformations = _parseTransformations(pathElement);
  final translation = _consumeTranslationIfPossible(transformations);
  final pathData = parsePathData(
    pathElement.getAttribute('d'),
    translation: translation,
  );
  return _buildVectorNodeFromPathData(pathElement, pathData, transformations);
}

VectorNode? _parseLineElement(XmlElement lineElement) {
  final mappedAttributes = _mapCoordinateAttributes(lineElement.attributes);
  final points = List.generate(4, (i) {
    final String name;
    switch (i) {
      case 0:
        name = 'x1';
        break;
      case 1:
        name = 'y1';
        break;
      case 2:
        name = 'x2';
        break;
      default:
        name = 'y2';
        break;
    }
    return mappedAttributes[name];
  });
  final transformations = _parseTransformations(lineElement);
  final pathData = _extractPathDataFromLinePoints(points, transformations);
  return _buildVectorNodeFromPathData(lineElement, pathData, transformations);
}

// polyshape => polyline or polygon
VectorNode? _parsePolyShapeElement(XmlElement polyShapeElement) {
  final points = polyShapeElement
      .getAttribute('points')
      ?.split(_definitionSeparatorPattern)
      .map(double.tryParse)
      .toList();
  final transformations = _parseTransformations(polyShapeElement);
  final pathData = _extractPathDataFromLinePoints(points, transformations);
  if (polyShapeElement.name.local == 'polygon') {
    pathData.add(PathNode(PathDataCommand.close, List.empty()));
  }
  return _buildVectorNodeFromPathData(
    polyShapeElement,
    pathData,
    transformations,
  );
}

VectorNode? _parseRectElement(XmlElement rectElement) {
  final transformations = _parseTransformations(rectElement);
  final translation =
      _consumeTranslationIfPossible(transformations).orDefault();
  final offsetX = translation.x;
  final offsetY = translation.y;
  final mappedAttributes = _mapCoordinateAttributes(rectElement.attributes);
  final x = (mappedAttributes['x'] ?? 0.0) + offsetX;
  final y = (mappedAttributes['y'] ?? 0.0) + offsetY;
  final width = mappedAttributes['width'];
  final height = mappedAttributes['height'];
  var rx = mappedAttributes['rx'];
  var ry = mappedAttributes['ry'];
  rx ??= ry ?? 0.0;
  ry ??= rx;
  if (width == null || height == null) return null;
  return _buildVectorNodeFromPathData(
    rectElement,
    obtainPathNodesForRectangle(
      bounds: Rect(x, y, width, height),
      radii: List.generate(
        8,
        ((index) => index.isEven ? rx! : ry!),
        growable: false,
      ),
    ),
    transformations,
  );
}

// circle included
VectorNode? _parseEllipseElement(XmlElement ellipseElement) {
  final transformations = _parseTransformations(ellipseElement);
  final translation =
      _consumeTranslationIfPossible(transformations).orDefault();
  final offsetX = translation.x;
  final offsetY = translation.y;
  final mappedAttributes = _mapCoordinateAttributes(ellipseElement.attributes);
  final cx = (mappedAttributes['cx'] ?? 0.0) + offsetX;
  final cy = (mappedAttributes['cy'] ?? 0.0) + offsetY;
  final double rx, ry;
  if (mappedAttributes.containsKey('r')) {
    rx = mappedAttributes['r'] ?? double.nan;
    ry = rx;
  } else {
    rx = mappedAttributes['rx'] ?? double.nan;
    ry = mappedAttributes['ry'] ?? double.nan;
  }
  if (rx == double.nan || ry == double.nan) return null;
  return _buildVectorNodeFromPathData(
    ellipseElement,
    obtainPathNodesForEllipse(cx: cx, cy: cy, rx: rx, ry: ry),
    transformations,
  );
}

Translation? _consumeTranslationIfPossible(Transformations? transformations) =>
    transformations != null && transformations.definesTranslationOnly
        ? transformations.consumeTranslation()
        : null;

VectorNode? _buildVectorNodeFromPathData(
  XmlElement sourceElement,
  List<PathNode> pathData,
  Transformations? transformations,
) {
  if (pathData.isEmpty) return null;
  if (sourceElement.parentElement!.name.local == 'clipPath') {
    // return now, we only care about the path data
    return VectorPathBuilder(pathData).build();
  }
  final pathBuilder = _fillPresentationAttributes(
    sourceElement,
    VectorPathBuilder(pathData),
  );
  // if transformations (other than a "simple" translation) are defined
  // for this path, wrap it in a group
  final nodeBuilder = (transformations != null
      ? VectorGroupBuilder()
          .transformations(transformations)
          .addNode(pathBuilder.build())
      : pathBuilder) as VectorNodeBuilder;
  return _handleClipPathAttribute(sourceElement, nodeBuilder) ??
      nodeBuilder.build();
}

// "terminal operation"
VectorGroup? _handleClipPathAttribute(
  XmlElement currentElement,
  VectorNodeBuilder currentBuilder,
) {
  final clipPathAttributeValue = currentElement.getAttribute('clip-path');
  if (!clipPathAttributeValue.isNullOrEmpty) {
    final referencedNodeId =
        extractIdFromUrlFunctionCall(clipPathAttributeValue!);
    final referencedNode = _definitions[referencedNodeId];
    if (referencedNode != null && referencedNode is List<VectorPath>) {
      return referencedNode.reversed
          .mapIndexed((index, e) {
            // if currentElement is a group, don't wrap it unnecessarily
            final isCurrentElementAGroup =
                index == 0 && currentBuilder is VectorGroupBuilder;
            final groupBuilder =
                (isCurrentElementAGroup ? currentBuilder : VectorGroupBuilder())
                    .clipPathData(e.pathData);
            if (!isCurrentElementAGroup) {
              groupBuilder.addNode(currentBuilder.build());
            }
            return groupBuilder;
          })
          .reduce((previous, current) => current.addNode(previous.build()))
          .build();
    }
  }
  return null;
}

List<PathNode> _extractPathDataFromLinePoints(
  List<double?>? points,
  Transformations? transformations,
) {
  if (points == null ||
      points.any((p) => p == null || !p.isFinite) ||
      points.length.isOdd) {
    return List.empty();
  }
  final translation = _consumeTranslationIfPossible(transformations);
  if (translation != null) {
    points = points
        .mapIndexed((i, p) => p! + (i.isEven ? translation.x : translation.y))
        .toList();
  }
  return [
    PathNode(PathDataCommand.moveTo, points.sublist(0, 2)),
    ...points
        .sublist(2)
        .chunked(2)
        .map((points) => PathNode(PathDataCommand.lineTo, points)),
  ];
}

// value is double.nan if it can't be parsed
Map<String, double> _mapCoordinateAttributes(List<XmlAttribute> attributes) =>
    Map.fromIterables(
      attributes.map((attr) => attr.name.local),
      attributes.map((attr) => attr.value.toDouble() ?? double.nan),
    );

B _fillPresentationAttributes<T extends VectorNode,
    B extends VectorNodeBuilder<T, B>>(
  XmlElement element,
  B builder,
) {
  for (final attribute in element.attributes) {
    final attributeName = attribute.name.local;
    final attributeValue = attribute.value;
    switch (attributeName) {
      case 'fill-rule':
        pathFillTypeFromString(attributeValue)?.let(builder.pathFillType);
        break;
      case 'id':
        builder.id(attributeValue);
        break;
      case 'opacity':
        _parsePercentage(attributeValue)?.let(builder.alpha);
        break;
      case 'fill':
        if (attributeValue == 'none') {
          builder.fill(Gradient.fromArgb(0));
        } else {
          _parseBrush(attributeValue)?.let(builder.fill);
        }
        break;
      case 'fill-opacity':
        _parsePercentage(attributeValue)?.let(builder.fillAlpha);
        break;
      case 'stroke':
        _parseBrush(attributeValue)?.let(builder.stroke);
        break;
      case 'stroke-opacity':
        _parsePercentage(attributeValue)?.let(builder.strokeAlpha);
        break;
      case 'stroke-width':
        _parseLength(attributeValue)?.let(builder.strokeLineWidth);
        break;
      case 'stroke-linecap':
        strokeCapFromString(attributeValue)?.let(builder.strokeLineCap);
        break;
      case 'stroke-linejoin':
        strokeJoinFromString(attributeValue)?.let(builder.strokeLineJoin);
        break;
      case 'stroke-miterlimit':
        attributeValue.toDouble()?.let(builder.strokeLineMiter);
        break;
    }
  }
  return builder;
}

Gradient? _parseGradient(XmlElement gradientElement) {
  final stopElements = gradientElement.findElements('stop');
  final colors = stopElements
      .map((stopElement) {
        final opacity = stopElement.getAttribute('stop-opacity')?.toDouble();
        final colorAttributeValue = stopElement.getAttribute('stop-color');
        final color = colorAttributeValue != null
            // the result is a Gradient with a single value
            ? _parseBrush(colorAttributeValue)?.colors.singleOrNull
            : null;
        if (color != null) {
          final currentOpacity = (opacity ?? 1) * ((color >> 24) / 0xFF);
          final newAlpha = (currentOpacity * 0xFF).round();
          return newAlpha << 24 | (color & 0x00FFFFFF);
        }
      })
      .whereNotNull()
      .toList();
  if (colors.isEmpty) {
    return null;
  }
  final stops = stopElements
      .mapIndexed((index, stopElement) {
        var offset = stopElement.getAttribute('offset')?.let(_parsePercentage)
            as double?;
        if (offset == null && index == 0) offset = 0.0;
        return offset;
      })
      .whereNotNull()
      .toList();
  if (stops.isNotEmpty && colors.length != stops.length) {
    return null;
  }
  final tileMode =
      gradientElement.getAttribute('spreadMethod')?.let(tileModeFromString);
  if (gradientElement.name.local.startsWith('linear')) {
    return LinearGradient(
      colors,
      stops: stops,
      startX: gradientElement.getAttribute('x1')?.toDouble(),
      startY: gradientElement.getAttribute('y1')?.toDouble(),
      endX: gradientElement.getAttribute('x2')?.toDouble(),
      endY: gradientElement.getAttribute('y2')?.toDouble(),
      tileMode: tileMode,
    );
  } else {
    return RadialGradient(
      colors,
      stops: stops,
      centerX: gradientElement.getAttribute('cx')?.toDouble(),
      centerY: gradientElement.getAttribute('cy')?.toDouble(),
      radius: gradientElement.getAttribute('r')?.toDouble(),
      tileMode: tileMode,
    );
  }
}

// TODO: support more units than px?
// values expressed as a percentage if `baseForPercentage` is null
// (typically unknown or not easily reachable)
double? _parseLength(String lengthAsString, {num? baseForPercentage}) {
  return baseForPercentage?.let((base) => _parsePercentage(lengthAsString)
          ?.let((percentage) => base * percentage)) ??
      lengthAsString
          .replaceFirst('px', '')
          .toDouble()
          ?.takeIf((l) => !l.isNegative);
}

// 0.0..1.0
double? _parsePercentage(String percentageAsString) {
  final trimmed = percentageAsString.trim();
  if (trimmed == '1') return 1.0;
  final valueToParse = trimmed.endsWith('%')
      ? trimmed.substring(0, trimmed.length - 1)
      : trimmed;
  return valueToParse.toDouble()?.let((it) {
    if (it.isNaN || it.isNegative || it > 100.0) return null;
    if (it >= 1.0) return it / 100.0;
    return it;
  });
}

Gradient? _parseBrush(String brushAsString) {
  Gradient? gradient;
  List<num?> extractDefinitionValues(String value, int prefixLength) => value
      .substring(prefixLength + 1, value.length - 1)
      .split(_definitionSeparatorPattern)
      .map(num.tryParse)
      .toList();

  if (brushAsString.startsWith('#')) {
    gradient = Gradient.fromHexString(brushAsString);
  } else if (brushAsString.startsWith('rgb(')) {
    final rgb = extractDefinitionValues(brushAsString, 4)
        .whereType<int>()
        .cast<int>()
        .toList();
    if (rgb.isNotEmpty && rgb.length == 3) {
      gradient = Gradient.fromArgbComponents(0xFF, rgb[0], rgb[1], rgb[2]);
    }
  } else if (brushAsString.startsWith('rgba(')) {
    final rgba =
        extractDefinitionValues(brushAsString, 5).whereNotNull().toList();
    final rgb = rgba.sublist(0, 4).whereType<int>().cast<int>().toList();
    final alpha = rgba.length == 4 ? rgba[3] * 0xFF ~/ 1 : null;
    if (alpha != null && rgb.isNotEmpty && rgb.length == 3) {
      gradient = Gradient.fromArgbComponents(alpha, rgb[0], rgb[1], rgb[2]);
    }
  } else if (brushAsString.startsWith('url(#')) {
    final id = extractIdFromUrlFunctionCall(brushAsString);
    final candidate = _definitions[id];
    if (candidate is Gradient) {
      gradient = candidate;
    }
  } else {
    switch (brushAsString) {
      case 'black':
        gradient = Gradient.fromArgbComponents(255, 0, 0, 0);
        break;
      case 'white':
        gradient = Gradient.fromArgbComponents(255, 255, 255, 255);
        break;
      // TODO: add more colors
    }
  }
  return gradient;
}

String extractIdFromUrlFunctionCall(String functionCallAsString) =>
    functionCallAsString
        .substring(5, functionCallAsString.length - 1)
        .replaceAll('\'', '');
