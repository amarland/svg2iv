import 'dart:io';

import 'package:collection/collection.dart';
import 'package:svg2iv/extensions.dart';
import 'package:svg2iv/file_parser.dart';
import 'package:svg2iv/model/gradient.dart';
import 'package:svg2iv/model/image_vector.dart';
import 'package:svg2iv/model/transformations.dart';
import 'package:svg2iv/model/vector_group.dart';
import 'package:svg2iv/model/vector_node.dart';
import 'package:svg2iv/model/vector_path.dart';
import 'package:svg2iv/path_data_parser.dart';
import 'package:tuple/tuple.dart';
import 'package:xml/xml.dart';

const _aaptNamespaceUri = 'http://schemas.android.com/aapt';
const _androidNamespaceUri = 'http://schemas.android.com/apk/res/android';

ImageVector parseVectorDrawableFile(File source) {
  final rootElement = parseXmlFile(source, expectedRootName: 'vector');
  final requiredAttributeNames = [
    'viewportWidth',
    'viewportHeight',
    'width',
    'height',
  ];
  final parsedRequiredAttributes =
      requiredAttributeNames.associate((name) => name, (name) {
    final valueAsString =
        rootElement.getAndroidNSAttribute(name)?.replaceFirst('dp', '', 1);
    return valueAsString != null ? double.tryParse(valueAsString) : null;
  });
  if (parsedRequiredAttributes.values.anyNull()) {
    throw FileParserException(
      'Missing required attribute(s): ' +
          parsedRequiredAttributes.entries
              .where((entry) => entry.value == null)
              .map((entry) => entry.key)
              .join(', '),
    );
  }
  final builder = ImageVectorBuilder(
    parsedRequiredAttributes['viewportWidth']!,
    parsedRequiredAttributes['viewportHeight']!,
  )
      .width(parsedRequiredAttributes['width']!)
      .height(parsedRequiredAttributes['height']!);
  final name = rootElement.getAndroidNSAttribute('name');
  if (name != null) {
    builder.name(name);
  }
  // TODO other attributes
  for (final element in rootElement.children.whereType<XmlElement>()) {
    switch (element.name.local) {
      case 'group':
        builder.addNodes(_parseGroupElement(element));
        break;
      case 'path':
        _parsePathElement(element)
            ?.let((vectorPath) => builder.addNode(vectorPath));
        break;
      case 'clip-path':
        _parseClipPathElement(element)?.let((group) => builder.addNode(group));
        break;
    }
  }
  return builder.build();
}

// can be a single group or the list of its nodes if it's considered "redundant"
Iterable<VectorNode> _parseGroupElement(XmlElement groupElement) {
  final attributes = groupElement.androidNSAttributes
      .associate((attr) => attr.name.local, (attr) => attr.value);
  final groupBuilder = VectorGroupBuilder();
  attributes['name']?.let((name) => groupBuilder.id(name));
  final transformationsBuilder = TransformationsBuilder();
  final rotationAngle = attributes['rotation']?.toDouble();
  if (rotationAngle != null) {
    transformationsBuilder.rotation(
      Rotation(
        rotationAngle,
        pivotX: attributes['pivotX']?.toDouble(),
        pivotY: attributes['pivotY']?.toDouble(),
      ),
    );
  }
  final scaleX = attributes['scaleX']?.toDouble();
  if (scaleX != null) {
    transformationsBuilder.scale(
      Scale(scaleX, attributes['scaleY']?.toDouble()),
    );
  }
  final translationX = attributes['translateX']?.toDouble();
  if (translationX != null) {
    transformationsBuilder.addTranslation(
      Translation(translationX, attributes['translateY']?.toDouble()),
    );
  }
  final transformations = transformationsBuilder.build();
  if (transformations != null) {
    groupBuilder.transformations(transformations);
  }
  final group = groupBuilder.build();
  return group.hasAttributes ? [group] : group.nodes;
}

VectorPath? _parsePathElement(XmlElement pathElement) {
  final pathData = parsePathData(pathElement.getAndroidNSAttribute('pathData'));
  if (pathData.isEmpty) return null;
  final builder = VectorPathBuilder(pathData);
  for (final attribute in pathElement.androidNSAttributes) {
    final attributeName = attribute.name.local;
    final attributeValue = attribute.value;
    switch (attributeName) {
      case 'fillType':
        pathFillTypeFromString(attributeValue)
            ?.let((fillType) => builder.pathFillType(fillType));
        break;
      case 'name':
        builder.id(attributeValue);
        break;
      case 'fillColor':
        Gradient.fromHexString(attributeValue)
            ?.let((fill) => builder.fill(fill));
        break;
      case 'fillAlpha':
        attributeValue
            .toDouble()
            ?.let((fillAlpha) => builder.fillAlpha(fillAlpha));
        break;
      case 'strokeColor':
        Gradient.fromHexString(attributeValue)
            ?.let((stroke) => builder.stroke(stroke));
        break;
      case 'strokeAlpha':
        attributeValue
            .toDouble()
            ?.let((strokeAlpha) => builder.strokeAlpha(strokeAlpha));
        break;
      case 'strokeWidth':
        attributeValue
            .toDouble()
            ?.let((strokeWidth) => builder.strokeLineWidth(strokeWidth));
        break;
      case 'strokeLineCap':
        strokeCapFromString(attributeValue)
            ?.let((strokeLineCap) => builder.strokeLineCap(strokeLineCap));
        break;
      case 'strokeLineJoin':
        strokeJoinFromString(attributeValue)
            ?.let((strokeLineJoin) => builder.strokeLineJoin(strokeLineJoin));
        break;
      case 'strokeLineMiter':
        attributeValue.toDouble()?.let(
            (strokeLineMiter) => builder.strokeLineMiter(strokeLineMiter));
        break;
      case 'trimPathStart':
        attributeValue
            .toDouble()
            ?.let((trimPathStart) => builder.trimPathStart(trimPathStart));
        break;
      case 'trimPathEnd':
        attributeValue
            .toDouble()
            ?.let((trimPathEnd) => builder.trimPathEnd(trimPathEnd));
        break;
      case 'trimPathOffset':
        attributeValue
            .toDouble()
            ?.let((trimPathOffset) => builder.trimPathOffset(trimPathOffset));
        break;
    }
  }
  final attrElements = pathElement.findElements(
    'attr',
    namespace: _aaptNamespaceUri,
  );
  for (final attrElement in attrElements) {
    final singleAttribute = attrElement.attributes.singleOrNull;
    if (singleAttribute == null || singleAttribute.name.local != 'name') {
      continue;
    }
    final singleChildElement =
        attrElement.children.whereType<XmlElement>().singleOrNull;
    if (singleChildElement == null ||
        singleChildElement.name.local != 'gradient') {
      continue;
    }
    final gradient = _parseGradient(singleChildElement);
    if (gradient == null) continue;
    switch (singleAttribute.value) {
      case 'android:fillColor':
        builder.fill(gradient);
        break;
      case 'android:strokeColor':
        builder.fill(gradient);
        break;
    }
  }
  return builder.build();
}

VectorGroup? _parseClipPathElement(XmlElement clipPathElement) {
  final clipPathData =
      parsePathData(clipPathElement.getAndroidNSAttribute('pathData'));
  return clipPathData.isNotEmpty
      ? VectorGroupBuilder().clipPathData(clipPathData).build()
      : null;
}

Gradient? _parseGradient(XmlElement gradientElement) {
  final gradientType = gradientElement.getAndroidNSAttribute('type');
  // TODO: support sweep gradients
  if (gradientType == null || gradientType == 'sweep') return null;
  final colorStops = _parseColorStops(gradientElement);
  final colors = colorStops.map((colorStop) => colorStop.item2).toList();
  final stops = colorStops.map((colorStop) => colorStop.item1).toList();
  final tileMode = gradientElement
      .getAndroidNSAttribute('tileMode')
      ?.let(tileModeFromString);
  if (gradientType == 'linear') {
    return LinearGradient(
      colors,
      stops: stops,
      startX: gradientElement.getAndroidNSAttribute('startX')?.toDouble(),
      startY: gradientElement.getAndroidNSAttribute('startY')?.toDouble(),
      endX: gradientElement.getAndroidNSAttribute('endX')?.toDouble(),
      endY: gradientElement.getAndroidNSAttribute('endY')?.toDouble(),
      tileMode: tileMode,
    );
  } else {
    return RadialGradient(
      colors,
      stops: stops,
      centerX: gradientElement.getAndroidNSAttribute('centerX')?.toDouble(),
      centerY: gradientElement.getAndroidNSAttribute('centerY')?.toDouble(),
      radius:
          gradientElement.getAndroidNSAttribute('gradientRadius')?.toDouble(),
      tileMode: tileMode,
    );
  }
}

Iterable<Tuple2<double, int>> _parseColorStops(XmlElement gradientElement) {
  final childElements = gradientElement.findElements('item');
  final lastIndex = childElements.length - 1;
  if (lastIndex >= 0) {
    return childElements.mapIndexed((index, item) {
      final offset = item.getAndroidNSAttribute('offset')?.toDouble() ??
          index / (lastIndex > 0 ? lastIndex : 1);
      final colorAsString = item.getAndroidNSAttribute('color');
      final colorInt = colorAsString != null
          ? Gradient.fromHexString(colorAsString)?.colors.singleOrNull
          : null;
      return colorInt != null ? Tuple2(offset, colorInt) : null;
    }).whereNotNull();
  } else {
    return gradientElement.androidNSAttributes
        .where((attr) => attr.name.local.endsWith('Color'))
        .map((attr) {
      final colorInt = Gradient.fromHexString(attr.value)?.colors.singleOrNull;
      if (colorInt == null) return null;
      final double offset;
      switch (attr.name.local) {
        case 'startColor':
          offset = 0.0;
          break;
        case 'centerColor':
          offset = 0.5;
          break;
        case 'endColor':
          offset = 1.0;
          break;
        default:
          return null;
      }
      return Tuple2(offset, colorInt);
    }).whereNotNull();
  }
}

extension _AndroidNSAttributeParsing on XmlElement {
  String? getAndroidNSAttribute(String name) =>
      getAttribute(name, namespace: _androidNamespaceUri);

  Iterable<XmlAttribute> get androidNSAttributes => attributes
      .where((attr) => attr.name.namespaceUri == _androidNamespaceUri);
}
