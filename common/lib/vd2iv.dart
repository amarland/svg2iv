import 'package:collection/collection.dart';
import 'package:xml/xml.dart';

import 'android_resources.dart';
import 'extensions.dart';
import 'file_parser.dart';
import 'model/gradient.dart';
import 'model/image_vector.dart';
import 'model/transformations.dart';
import 'model/vector_group.dart';
import 'model/vector_node.dart';
import 'model/vector_path.dart';
import 'path_data_parser.dart';

ImageVector parseVectorDrawableElement(XmlElement rootElement) {
  final parsedRequiredAttributes = <String, dynamic>{
    'viewportWidth': rootElement.getAndroidNSAttribute<double>('viewportWidth'),
    'viewportHeight':
        rootElement.getAndroidNSAttribute<double>('viewportHeight'),
    'width': rootElement.getAndroidNSAttribute<Dimension>('width'),
    'height': rootElement.getAndroidNSAttribute<Dimension>('height'),
  };
  if (parsedRequiredAttributes.values.anyNull()) {
    throw FileParserException(
      'Missing required attribute(s): ' +
          parsedRequiredAttributes.entries
              .where((entry) => entry.value == null)
              .map((entry) => entry.key)
              .join(', '),
    );
  }
  final viewportWidth = parsedRequiredAttributes['viewportWidth']!;
  final viewportHeight = parsedRequiredAttributes['viewportHeight']!;
  final builder = ImageVectorBuilder(viewportWidth, viewportHeight)
      .width((parsedRequiredAttributes['width']! as Dimension).value)
      .height((parsedRequiredAttributes['height']! as Dimension).value);
  rootElement.getAndroidNSAttribute<String>('name')?.let(builder.name);
  rootElement
      .getAndroidNSAttribute<Gradient>('tintColor')
      ?.colors
      .singleOrNull
      ?.let(builder.tintColor);
  rootElement
      .getAndroidNSAttribute<String>('tintBlendMode')
      ?.let(blendModeFromString)
      ?.let(builder.tintBlendMode);
  for (final element in rootElement.children.whereType<XmlElement>()) {
    switch (element.name.local) {
      case 'group':
        builder.addNodes(_parseGroupElement(element));
        break;
      case 'path':
        _parsePathElement(element)?.let(builder.addNode);
        break;
      case 'clip-path':
        _parseClipPathElement(element)?.let(builder.addNode);
        break;
    }
  }
  return builder.build();
}

// can be a single group or the list of its nodes if it's considered "redundant"
Iterable<VectorNode> _parseGroupElement(XmlElement groupElement) {
  final attributes = groupElement.androidNSAttributes
      .associate((attr) => attr.name.local, (attr) => attr);
  final groupBuilder = VectorGroupBuilder();
  attributes['name']?.let(parseAndroidResourceValue).let(groupBuilder.id);
  final transformationsBuilder = TransformationsBuilder();
  final rotationAngle =
      attributes['rotation']?.let((v) => parseAndroidResourceValue<double>(v));
  if (rotationAngle != null) {
    transformationsBuilder.rotate(
      angleInDegrees: rotationAngle,
      pivotX: attributes['pivotX']
          ?.let((v) => parseAndroidResourceValue<double>(v)),
      pivotY: attributes['pivotY']
          ?.let((v) => parseAndroidResourceValue<double>(v)),
    );
  }
  final scaleX =
      attributes['scaleX']?.let((v) => parseAndroidResourceValue<double>(v));
  if (scaleX != null) {
    transformationsBuilder.scale(
      x: scaleX,
      y: attributes['scaleY']?.let((v) => parseAndroidResourceValue<double>(v)),
    );
  }
  final translationX = attributes['translateX']
      ?.let((v) => parseAndroidResourceValue<double>(v));
  final translationY = attributes['translateY']
      ?.let((v) => parseAndroidResourceValue<double>(v));
  if (translationX != null || translationY != null) {
    transformationsBuilder.translate(
      x: translationX ?? 0.0,
      y: translationY ?? 0.0,
    );
  }
  final transformations = transformationsBuilder.build();
  if (transformations != null) {
    groupBuilder.transformations(transformations);
  }
  final group = groupBuilder.build();
  return group.id != null || group.definesTransformations
      ? [group]
      : group.nodes;
}

VectorPath? _parsePathElement(XmlElement pathElement) {
  final pathData = parsePathData(
    pathElement.getAndroidNSAttribute<String>('pathData'),
  );
  if (pathData.isEmpty) return null;
  final builder = VectorPathBuilder(pathData);
  for (final attribute in pathElement.androidNSAttributes) {
    final attributeName = attribute.name.local;
    switch (attributeName) {
      case 'fillType':
        final PathFillType? pathFillType =
            parseAndroidResourceValue<String>(attribute)
                ?.let(pathFillTypeFromString);
        pathFillType?.let(builder.pathFillType);
        break;
      case 'name':
        parseAndroidResourceValue<String>(attribute)?.let(builder.id);
        break;
      case 'fillColor':
        parseAndroidResourceValue<Gradient>(attribute)?.let(builder.fill);
        break;
      case 'fillAlpha':
        parseAndroidResourceValue<double>(attribute)?.let(builder.fillAlpha);
        break;
      case 'strokeColor':
        parseAndroidResourceValue<Gradient>(attribute)?.let(builder.stroke);
        break;
      case 'strokeAlpha':
        parseAndroidResourceValue<double>(attribute)?.let(builder.strokeAlpha);
        break;
      case 'strokeWidth':
        parseAndroidResourceValue<double>(attribute)
            ?.let(builder.strokeLineWidth);
        break;
      case 'strokeLineCap':
        parseAndroidResourceValue<String>(attribute)
            ?.let(strokeCapFromString)
            ?.let(builder.strokeLineCap);
        break;
      case 'strokeLineJoin':
        parseAndroidResourceValue<String>(attribute)
            ?.let(strokeJoinFromString)
            ?.let(builder.strokeLineJoin);
        break;
      case 'strokeLineMiter':
        parseAndroidResourceValue<double>(attribute)
            ?.let(builder.strokeLineMiter);
        break;
      case 'trimPathStart':
        parseAndroidResourceValue<double>(attribute)
            ?.let(builder.trimPathStart);
        break;
      case 'trimPathEnd':
        parseAndroidResourceValue<double>(attribute)?.let(builder.trimPathEnd);
        break;
      case 'trimPathOffset':
        parseAndroidResourceValue<double>(attribute)
            ?.let(builder.trimPathOffset);
        break;
    }
  }
  final attrElements =
      pathElement.findElements('attr', namespace: aaptNamespaceUri);
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
    final gradient = parseGradient(singleChildElement);
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
      parsePathData(clipPathElement.getAndroidNSAttribute<String>('pathData'));
  return clipPathData.isNotEmpty
      ? VectorGroupBuilder().clipPathData(clipPathData).build()
      : null;
}
