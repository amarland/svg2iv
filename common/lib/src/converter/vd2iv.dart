// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:collection/collection.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart' as vgc;
import 'package:xml/xml.dart';

import '../../models.dart';
import '../extensions.dart';
import '../file_parser.dart';
import '../util/android_resources.dart';
import '../util/path_command_mapper.dart';

ImageVector parseVectorDrawableElement(XmlElement rootElement) {
  final parsedRequiredAttributes = <String, dynamic>{
    'viewportWidth': rootElement.getAndroidNSAttribute<double>('viewportWidth'),
    'viewportHeight':
        rootElement.getAndroidNSAttribute<double>('viewportHeight'),
    'width': rootElement.getAndroidNSAttribute<Dimension>('width'),
    'height': rootElement.getAndroidNSAttribute<Dimension>('height'),
  };
  if (parsedRequiredAttributes.values.anyNull()) {
    throw ParserException(
      'Missing required attribute(s): ' +
          parsedRequiredAttributes.entries
              .where((entry) => entry.value == null)
              .map((entry) => entry.key)
              .join(', '),
    );
  }
  final viewportWidth = parsedRequiredAttributes['viewportWidth'] as double;
  final viewportHeight = parsedRequiredAttributes['viewportHeight'] as double;
  final builder = ImageVectorBuilder(viewportWidth, viewportHeight)
      .width((parsedRequiredAttributes['width'] as Dimension).value)
      .height((parsedRequiredAttributes['height'] as Dimension).value);
  rootElement.getAndroidNSAttribute<String>('name')?.let(builder.name);
  rootElement
      .getAndroidNSAttribute<SolidColor>('tintColor')
      ?.colorInt
      .let(builder.tintColor);
  rootElement
      .getAndroidNSAttribute<String>('tintBlendMode')
      ?.let(_blendModeFromString)
      ?.let(builder.tintBlendMode);
  for (final element in rootElement.childElements) {
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
  attributes['name']
      ?.let((n) => parseAndroidResourceValue<String>(n))
      ?.let((n) => groupBuilder.id(n));
  final transformationsBuilder = TransformationsBuilder();
  final rotationAngle =
      attributes['rotation']?.let((v) => parseAndroidResourceValue<double>(v));
  if (rotationAngle != null) {
    transformationsBuilder.rotate(
      rotationAngle,
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
  final pathData = _parsePathDataAttribute(pathElement);
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
        parseAndroidResourceValue<SolidColor>(attribute)?.let(builder.fill);
        break;
      case 'fillAlpha':
        parseAndroidResourceValue<double>(attribute)?.let(builder.fillAlpha);
        break;
      case 'strokeColor':
        parseAndroidResourceValue<SolidColor>(attribute)?.let(builder.stroke);
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
    final singleChildElement = attrElement.childElements.singleOrNull;
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
  final clipPathData = _parsePathDataAttribute(clipPathElement);
  return clipPathData.isNotEmpty
      ? VectorGroupBuilder().clipPathData(clipPathData).build()
      : null;
}

BlendMode? _blendModeFromString(String valueAsString) {
  switch (valueAsString.toLowerCase()) {
    case 'src_over':
      return BlendMode.srcOver;
    case 'src_in':
      return BlendMode.srcIn;
    case 'src_atop':
      return BlendMode.srcAtop;
    // https://cs.android.com/androidx/platform/frameworks/support/+/androidx-main:compose/ui/ui/src/androidMain/kotlin/androidx/compose/ui/graphics/vector/compat/XmlVectorParser.android.kt;l=228
    // "b/73224934 PorterDuff Multiply maps to Skia Modulate"
    case 'multiply':
      return BlendMode.modulate;
    case 'screen':
      return BlendMode.screen;
    case 'add':
      return BlendMode.plus;
  }
  return null;
}

List<PathNode> _parsePathDataAttribute(XmlElement pathElement) {
  final pathDataAsString =
      pathElement.getAndroidNSAttribute<String>('pathData');
  if (pathDataAsString.isNullOrEmpty) return List.empty();
  return mapPathCommands(vgc.parseSvgPathData(pathDataAsString!));
}
