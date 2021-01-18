import 'dart:io';

import 'package:collection/collection.dart';
import 'package:svg2va/extensions.dart';
import 'package:svg2va/model/gradient.dart';
import 'package:svg2va/model/image_vector.dart';
import 'package:svg2va/model/transformations.dart';
import 'package:svg2va/model/vector_group.dart';
import 'package:svg2va/model/vector_node.dart';
import 'package:svg2va/model/vector_path.dart';
import 'package:svg2va/path_data_parser.dart';
import 'package:svg2va/preprocessor.dart';
import 'package:svg2va/svg_parser_exception.dart';
import 'package:xml/xml.dart';

final _definitionSeparatorPattern = RegExp(r'[,\s]\s*');

final Map<String, dynamic> _definitions = {};

ImageVector parseSvgFile(File source) {
  final XmlDocument document;
  try {
    document = XmlDocument.parse(source.readAsStringSync());
  } on FileSystemException {
    throw SvgParserException('The file could not be read.');
  } on XmlParserException {
    throw SvgParserException('The contents of the file could not be parsed.');
  }
  final rootElement = document.rootElement;
  try {
    if (rootElement.name.local != 'svg') {
      throw SvgParserException('The root element is not an `svg` element.');
    }
  } on StateError {
    throw SvgParserException('The file is empty.');
  }
  preprocessSvg(rootElement);
  double? viewportWidth;
  double? viewportHeight;
  double? width;
  double? height;
  final viewBox = rootElement
      .getAttribute('viewBox')
      ?.split(_definitionSeparatorPattern)
      .map(double.tryParse)
      .toList()
      .takeIf((viewBox) => viewBox.length != 4 || viewBox.sublist(2).anyNull());
  final widthAsString = rootElement.getAttribute('width');
  final heightAsString = rootElement.getAttribute('height');
  if (viewBox != null) {
    viewportWidth = viewBox[2]!;
    viewportHeight = viewBox[3]!;
  }
  if (!widthAsString.isNullOrEmpty &&
      !widthAsString!.endsWith('%') &&
      !heightAsString.isNullOrEmpty &&
      !heightAsString!.endsWith('%')) {
    width = double.tryParse(widthAsString);
    height = double.tryParse(heightAsString);
  }
  viewportWidth ??= width;
  viewportHeight ??= height;
  if (viewportWidth == null || viewportHeight == null) {
    throw SvgParserException(
      'The size of the viewport could not be determined.',
    );
  }
  final builder = ImageVectorBuilder(viewportWidth, viewportHeight);
  rootElement.getAttribute('id')?.let(builder.name);
  if (width == null && widthAsString != null) {
    width = _parseLength(widthAsString, viewportWidth);
  }
  if (height == null && heightAsString != null) {
    height = _parseLength(heightAsString, viewportHeight);
  }
  width?.let(builder.width);
  height?.let(builder.height);
  for (final node in _extractNodesOfInterest(rootElement)) {
    builder.addNode(node);
  }
  _definitions.clear();
  return builder.build();
}

Iterable<VectorNode> _extractNodesOfInterest(XmlElement rootElement) sync* {
  for (final element in rootElement.children.whereType<XmlElement>().where(
      (element) =>
          element.getAttribute('display')?.let((value) => value != 'none'))) {
    VectorNode? node;
    switch (element.name.local) {
      case 'defs':
        final gradientElements = element.children.whereType<XmlElement>().where(
          (element) {
            final elementName = element.name.local;
            return elementName == 'linearGradient' ||
                elementName == 'radialGradient';
          },
        );
        for (final gradientElement in gradientElements) {
          final id = gradientElement.getAttribute('id');
          if (!id.isNullOrEmpty) {
            _parseGradient(gradientElement)?.let(
              (gradient) => _definitions[id!] = gradient,
            );
          }
        }
        final identifiedNodes =
            _extractNodesOfInterest(element).where((n) => !n.id.isNullOrEmpty);
        for (final node in identifiedNodes) {
          _definitions[node.id!] = node;
        }
        break;
      case 'g':
        node = _parseGroupElement(element);
        break;
      case 'path':
        node = _parsePathElement(element);
        break;
      case 'line':
        node = _parseLineElement(element);
        break;
      case 'polyline':
      case 'polygon':
        node = _parsePolyShapeElement(element);
        break;
      case 'rect':
        node = _parseRectElement(element);
        break;
      case 'circle':
      case 'ellipse':
        node = _parseEllipseElement(element);
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
          paths
              .takeIf((it) => it.isNotEmpty)
              ?.let((paths) => _definitions[id!] = paths);
        }
        break;
    }
    if (node != null) yield node;
  }
}

VectorGroup _parseGroupElement(XmlElement groupElement) {
  var builder = VectorGroupBuilder();
  _parseTransformations(groupElement)?.let((t) => builder.transformations(t));
  for (final childNode in _extractNodesOfInterest(groupElement)) {
    builder.addNode(childNode);
  }
  builder = _fillAttributes(groupElement, builder);
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
        .toList()
        .whereNotNull();
    switch (name) {
      case 'translate':
        final count = parsedValues.length;
        if (parsedValues.isNotEmpty && count <= 2) {
          builder.addTranslation(
            Translation(
              parsedValues[0],
              count == 2 ? parsedValues[1] : null,
            ),
          );
        }
        break;
      case 'scale':
        final count = parsedValues.length;
        if (parsedValues.isNotEmpty && count <= 2) {
          builder.scale(
            Scale(
              parsedValues[0],
              count == 2 ? parsedValues[1] : null,
            ),
          );
        }
        break;
      case 'rotate':
        final count = parsedValues.length;
        if (parsedValues.isNotEmpty && count <= 3) {
          builder.rotation(
            Rotation(
              parsedValues[0],
              pivotX: count >= 2 ? parsedValues[1] : null,
              pivotY: count == 3 ? parsedValues[2] : null,
            ),
          );
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
        (attr) => double.tryParse(attr.value),
      );
  final offsetX = customAttributes['x'];
  final offsetY = customAttributes['y'];
  if (offsetX != null && offsetY != null) {
    builder.addTranslation(Translation(offsetX, offsetY));
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
  }).toList();
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
    pathData?.add(PathNode(PathDataCommand.close, List.empty()));
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
  final width = mappedAttributes['width'] ?? double.nan;
  final height = mappedAttributes['height'] ?? double.nan;
  var rx = mappedAttributes['rx'];
  var ry = mappedAttributes['ry'];
  rx ??= ry;
  ry ??= rx;
  if (width == double.nan || height == double.nan) return null;
  final List<PathNode> pathData;
  if (rx != null && ry != null) {
    /*
    pathData = _extractPathDataFromLinePoints(
      // M x,y h x,width v y,height h x,-width v y,-height
      [x, y, x, width, y, height, x, -width, y, -height],
    );
    */
    pathData = [
      PathNode(PathDataCommand.moveTo, [x, y]),
      PathNode(PathDataCommand.relativeHorizontalLineTo, [width]),
      PathNode(PathDataCommand.relativeVerticalLineTo, [height]),
      PathNode(PathDataCommand.relativeHorizontalLineTo, [-width]),
      PathNode(PathDataCommand.close, List.empty()),
    ];
  } else {
    if (rx! > width / 2) rx = width / 2;
    if (ry! > height / 2) ry = height / 2;
    pathData = [
      PathNode(PathDataCommand.moveTo, [x + rx, y]),
      PathNode(PathDataCommand.lineTo, [x + width - rx, y]),
      PathNode(
        PathDataCommand.arcTo,
        [rx, ry, 0.0, false, true, x + width, y + ry],
      ),
      PathNode(PathDataCommand.lineTo, [x + width, y + height - ry]),
      PathNode(
        PathDataCommand.arcTo,
        [rx, ry, 0.0, false, true, x + width - rx, y + height],
      ),
      PathNode(
        PathDataCommand.lineTo,
        [x + rx, y + height],
      ),
      PathNode(PathDataCommand.arcTo,
          [rx, ry, 0.0, false, true, x, y + height - ry]),
      PathNode(PathDataCommand.lineTo, [x, y + ry]),
      PathNode(
        PathDataCommand.arcTo,
        [rx, ry, 0.0, false, true, x + rx, y],
      ),
    ];
  }
  return _buildVectorNodeFromPathData(rectElement, pathData, transformations);
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
  final isShapeACircle = mappedAttributes.containsKey('r');
  if (isShapeACircle) {
    rx = mappedAttributes['r'] ?? double.nan;
    ry = rx;
  } else {
    rx = mappedAttributes['rx'] ?? double.nan;
    ry = mappedAttributes['ry'] ?? double.nan;
  }
  if (rx == double.nan || ry == double.nan) return null;
  final sweepFlag = isShapeACircle;
  final diameter = 2 * rx;
  final pathData = [
    PathNode(PathDataCommand.moveTo, [cx - rx, cy]),
    PathNode(
      PathDataCommand.arcTo,
      [rx, ry, 0.0, true, sweepFlag, diameter, 0],
    ),
    PathNode(
      PathDataCommand.arcTo,
      [rx, ry, 0.0, true, sweepFlag, -diameter, 0],
    ),
    if (isShapeACircle) PathNode(PathDataCommand.close, List.empty())
  ];
  return _buildVectorNodeFromPathData(
    ellipseElement,
    pathData,
    transformations,
  );
}

Translation? _consumeTranslationIfPossible(Transformations? transformations) =>
    transformations != null && transformations.definesTranslationOnly
        ? transformations.consumeTranslation()
        : null;

VectorNode? _buildVectorNodeFromPathData(
  XmlElement sourceElement,
  List<PathNode>? pathData,
  Transformations? transformations,
) {
  if (pathData.isNullOrEmpty) return null;
  if (sourceElement.parentElement!.name.local == 'clipPath') {
    // return now, we only care about the path data
    return VectorPathBuilder(pathData!).build();
  }
  final pathBuilder = _fillAttributes(
    sourceElement,
    VectorPathBuilder(pathData!),
  );
  // if transformations (other than a "simple" translation) are defined
  // for this path, wrap it in a group
  final nodeBuilder = (transformations != null
      ? VectorGroupBuilder().addNode(pathBuilder.build())
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
  if (clipPathAttributeValue.isNullOrEmpty) {
    final referencedNodeId =
        extractIdFromUrlFunctionCall(clipPathAttributeValue!);
    final referencedNode = _definitions[referencedNodeId];
    if (referencedNode != null && referencedNode is List<VectorPath>) {
      return referencedNode.reversed
          .mapIndexed((index, e) {
            // if currentElement is a group, don't wrap it unnecessarily
            final isCurrentElementAGroup =
                index == 0 && currentBuilder is VectorGroupBuilder;
            final groupBuilder = (isCurrentElementAGroup
                    ? currentBuilder as VectorGroupBuilder
                    : VectorGroupBuilder())
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
}

List<PathNode>? _extractPathDataFromLinePoints(
  List<double?>? points,
  Transformations? transformations,
) {
  if (points == null ||
      points.any((p) => p == null || !p.isFinite) ||
      points.length.isOdd) return null;
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
      attributes.map((attr) => double.tryParse(attr.value) ?? double.nan),
    );

B _fillAttributes<T extends VectorNode, B extends VectorNodeBuilder<T, B>>(
  XmlElement element,
  B builder,
) {
  for (final attribute in element.attributes) {
    final attributeName = attribute.name.local;
    final attributeValue = attribute.value;
    switch (attributeName) {
      case 'fill-rule':
        PathFillType? fillType;
        switch (attributeValue) {
          case 'nonzero':
            fillType = PathFillType.nonZero;
            break;
          case 'evenodd':
            fillType = PathFillType.evenOdd;
            break;
        }
        fillType?.let((fillType) => builder.pathFillType(fillType));
        break;
      case 'id':
        builder.id(attributeValue);
        break;
      case 'fill':
        _parseColor(attributeValue)?.let((fill) => builder.fill(fill));
        break;
      case 'fill-opacity':
        _parsePercentage(attributeValue)
            ?.let((fillAlpha) => builder.fillAlpha(fillAlpha));
        break;
      case 'opacity':
        _parseColor(attributeValue)?.let((stroke) => builder.stroke(stroke));
        break;
      case 'stroke-opacity':
        _parsePercentage(attributeValue)?.let(
          (strokeAlpha) => builder.strokeAlpha(strokeAlpha),
        );
        break;
      case 'stroke-linecap':
        StrokeCap? strokeLineCap;
        switch (attributeValue) {
          case 'butt':
            strokeLineCap = StrokeCap.butt;
            break;
          case 'round':
            strokeLineCap = StrokeCap.round;
            break;
          case 'square':
            strokeLineCap = StrokeCap.square;
            break;
        }
        strokeLineCap?.let(
          (strokeLineCap) => builder.strokeLineCap(strokeLineCap),
        );
        break;
      case 'stroke-linejoin':
        StrokeJoin? strokeLineJoin;
        switch (attributeValue) {
          case 'bevel':
            strokeLineJoin = StrokeJoin.bevel;
            break;
          case 'miter':
            strokeLineJoin = StrokeJoin.miter;
            break;
          case 'round':
            strokeLineJoin = StrokeJoin.round;
            break;
        }
        strokeLineJoin?.let(
          (strokeLineJoin) => builder.strokeLineJoin(strokeLineJoin),
        );
        break;
      case 'stroke-miterlimit':
        double.tryParse(attributeValue)?.let(
            (strokeLineMiter) => builder.strokeLineMiter(strokeLineMiter));
        break;
    }
  }
  return builder;
}

Gradient? _parseGradient(XmlElement gradientElement) {
  double? getAttributeAsDouble(String name) =>
      gradientElement.getAttribute(name)?.let(double.tryParse);

  final x1 = getAttributeAsDouble('x1');
  final y1 = getAttributeAsDouble('y1');
  final x2 = getAttributeAsDouble('x2');
  final y2 = getAttributeAsDouble('y2');
  final cx = getAttributeAsDouble('cx');
  final cy = getAttributeAsDouble('cy');
  final radius = getAttributeAsDouble('r');
  final stopElements = gradientElement.findElements('stop');
  final colors = stopElements
      .map((stopElement) {
        final opacityAttributeValue = stopElement.getAttribute('stop-opacity');
        final opacity = (opacityAttributeValue != null
            ? double.tryParse(opacityAttributeValue)
            : null);
        final colorAttributeValue = stopElement.getAttribute('stop-color');
        final color = colorAttributeValue != null
            // we know it's not an actual gradient
            ? _parseColor(colorAttributeValue)?.colors.singleOrNull
            : null;
        if (color != null) {
          final currentOpacity = (opacity ?? 1) * ((color >> 24) / 0xFF);
          final newAlpha = (currentOpacity * 0xFF).round();
          return newAlpha | (color & 0x00FFFFFF);
        }
      })
      .toList()
      .whereNotNull();
  if (colors.isEmpty) {
    return null;
  }
  final stops = stopElements
      .map((stopElement) {
        final offsetAttributeValue = stopElement.getAttribute('offset');
        return offsetAttributeValue != null
            ? _parsePercentage(offsetAttributeValue)
            : null;
      })
      .toList()
      .whereNotNull();
  if (stops.isNotEmpty && colors.length != stops.length) {
    return null;
  }
  TileMode? tileMode;
  switch (gradientElement.getAttribute('spreadMethod')) {
    case 'pad':
      tileMode = TileMode.clamp;
      break;
    case 'repeat':
      tileMode = TileMode.repeated;
      break;
    case 'reflect':
      tileMode = TileMode.mirror;
      break;
  }
  return gradientElement.name.local.startsWith('linear')
      ? LinearGradient(
          colors,
          stops: stops,
          startX: x1,
          startY: y1,
          endX: x2,
          endY: y2,
          tileMode: tileMode,
        )
      : RadialGradient(
          colors,
          stops: stops,
          centerX: cx,
          centerY: cy,
          radius: radius,
          tileMode: tileMode,
        );
}

// TODO: support other units?
double? _parseLength(String lengthAsString, num base) =>
    _parsePercentage(lengthAsString)?.let((percentage) => base * percentage) ??
    double.tryParse(lengthAsString.replaceFirst('px', ''))
        ?.takeIf((l) => !l.isNegative);

double? _parsePercentage(String percentageAsString) {
  final trimmed = percentageAsString.trim();
  final valueToParse = trimmed.endsWith('%')
      ? trimmed.substring(0, trimmed.length - 1)
      : trimmed;
  return double.tryParse(valueToParse)?.let((it) => it / 100);
}

Gradient? _parseColor(String colorAsString) {
  Gradient colorToGradient(int alpha, int red, int green, int blue) =>
      LinearGradient([(alpha << 24) | (red << 16) | (green << 8) | blue]);

  Gradient? gradient;
  List<num?> extractDefinitionValues(String value, int prefixLength) => value
      .substring(prefixLength + 1, value.length - 1)
      .split(_definitionSeparatorPattern)
      .map(num.tryParse)
      .toList();

  if (colorAsString.startsWith('#')) {
    final valueAsList = colorAsString.substring(1).split('');
    final List<int?> argb;
    if (valueAsList.length == 3) {
      argb = valueAsList.map((s) {
        final digit = int.tryParse(s, radix: 16);
        return digit != null ? digit * 10 + digit : null;
      }).toList();
    } else if (valueAsList.length >= 6) {
      final int? alpha;
      final List<String?> rgb;
      if (valueAsList.length == 8) {
        alpha = int.tryParse(valueAsList.sublist(0, 2).join(), radix: 16);
        rgb = valueAsList.sublist(2);
      } else {
        alpha = 0xFF;
        rgb = valueAsList;
      }
      argb = <int?>[
        alpha,
        ...rgb
            .chunked(2)
            .map((digits) => int.tryParse(digits.join(), radix: 16))
      ];
    } else {
      argb = List.empty();
    }
    if (argb.isNotEmpty && argb.everyNotNull()) {
      gradient = colorToGradient(argb[0]!, argb[1]!, argb[2]!, argb[3]!);
    }
  } else if (colorAsString.startsWith('rgb(')) {
    final rgb = extractDefinitionValues(colorAsString, 4)
        .whereType<int>()
        .cast<int>()
        .toList();
    if (rgb.isNotEmpty && rgb.length == 3) {
      gradient = colorToGradient(0xFF, rgb[0], rgb[1], rgb[2]);
    }
  } else if (colorAsString.startsWith('rgba(')) {
    final rgba = extractDefinitionValues(colorAsString, 5).whereNotNull();
    final rgb = rgba.sublist(0, 4).whereType<int>().cast<int>().toList();
    final alpha = rgba.length == 4 ? rgba[3] * 0xFF ~/ 1 : null;
    if (alpha != null && rgb.isNotEmpty && rgb.length == 3) {
      gradient = colorToGradient(alpha, rgb[0], rgb[1], rgb[2]);
    }
  } else if (colorAsString.startsWith('url(#')) {
    final id = extractIdFromUrlFunctionCall(colorAsString);
    final candidate = _definitions[id];
    if (candidate is Gradient) {
      gradient = candidate;
    }
  } else {
    switch (colorAsString) {
      case 'black':
        gradient = colorToGradient(255, 0, 0, 0);
        break;
      case 'white':
        gradient = colorToGradient(255, 255, 255, 255);
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
