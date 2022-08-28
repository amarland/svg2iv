import 'package:collection/collection.dart';
import 'package:tuple/tuple.dart';
import 'package:xml/xml.dart';

import '../extensions.dart';
import '../file_parser.dart';
import '../model/brush.dart';
import '../util/path_building_helpers.dart';

const aaptNamespaceUri = 'http://schemas.android.com/aapt';
const androidNamespaceUri = 'http://schemas.android.com/apk/res/android';

// used to differentiate dimensions (expressed in dp/px) from numerical values
class Dimension {
  const Dimension(this.value);

  final double value;
}

extension AndroidNSAttributeParsing on XmlElement {
  T? getAndroidNSAttribute<T>(String name) =>
      getAttributeNode(name, namespace: androidNamespaceUri)
          ?.let((value) => parseAndroidResourceValue<T>(value));

  Iterable<XmlAttribute> get androidNSAttributes =>
      attributes.where((attr) => attr.name.namespaceUri == androidNamespaceUri);
}

T? parseAndroidResourceValue<T>(XmlAttribute attribute) {
  final attributeValue = attribute.value;
  if (attributeValue[0] == '?' ||
      attributeValue.startsWith(RegExp(r'(?:android\.)?R\.|\?'))) {
    throw ParserException(
      '''
Reference found for XML attribute '${attribute.name}': '$attributeValue'
References to theme attributes and/or to Android resources'''
      ' are not supported because they cannot be resolved by this tool.',
    );
  }
  switch (T) {
    case Dimension:
      final numericalValue = attributeValue
          .replaceFirst(RegExp('dp|px'), '', 1)
          // valid only if a dimension unit is specified
          // => unless the string hasn't changed
          .takeIf((it) => it != attributeValue)
          ?.toDouble();
      if (numericalValue == null) {
        throw ParserException(
          "Expected a dimension for XML attribute '${attribute.name}';"
          """ found '$attributeValue'
Dimensions expressed in units other than density-independent pixels (dp)"""
          ' and pixels (px) are not supported.',
        );
      }
      return Dimension(numericalValue) as T;
    case double:
      return attributeValue.toDouble() as T?;
    case int:
      return attributeValue.toInt() as T?;
    case String:
      return attributeValue as T;
    case SolidColor:
      return SolidColor.fromHexString(attributeValue) as T?;
  }
  throw ParserException(
    "Unexpected value for XML attribute '${attribute.name}': '$attributeValue'",
  );
}

Gradient? parseGradient(XmlElement gradientElement, [Rect? bounds]) {
  final gradientType = gradientElement.getAndroidNSAttribute<String>('type');
  // TODO: support sweep gradients
  if (gradientType == null || gradientType == 'sweep') return null;
  final colorStops = _parseGradientColorStops(gradientElement);
  final colors = colorStops.map((colorStop) => colorStop.item2).toList();
  final stops = colorStops.map((colorStop) => colorStop.item1).toList();
  final tileMode = gradientElement
      .getAndroidNSAttribute<String>('tileMode')
      ?.let(tileModeFromString);
  // if `bounds` is not null, it is assumed the gradient
  // is from a gradient drawable
  final isFromGradientDrawable = bounds != null;
  if (gradientType == 'linear') {
    double? startX;
    double? startY;
    double? endX;
    double? endY;
    if (isFromGradientDrawable) {
      // 270 = top to bottom, the default
      final angle = gradientElement.getAndroidNSAttribute<int>('angle') ?? 270;
      if (angle % 45 != 0) {
        throw ParserException(
          'The angle for the gradient must be a multiple of 45.',
        );
      }
      switch (angle % 360) {
        case 0:
          startX = endX = bounds.left;
          startY = endY = bounds.top;
          break;
        case 45:
          startX = bounds.left;
          endX = bounds.right;
          startY = bounds.bottom;
          endY = bounds.top;
          break;
        case 90:
          startX = endX = bounds.left;
          startY = bounds.bottom;
          endY = bounds.top;
          break;
        case 135:
          startX = bounds.right;
          endX = bounds.left;
          startY = bounds.bottom;
          endY = bounds.top;
          break;
        case 180:
          startX = endX = bounds.right;
          startY = endY = bounds.top;
          break;
        case 225:
          startX = bounds.right;
          endX = bounds.left;
          startY = bounds.top;
          endY = bounds.bottom;
          break;
        case 270:
          startX = endX = bounds.left;
          startY = bounds.top;
          endY = bounds.bottom;
          break;
        case 315:
          startX = bounds.left;
          endX = bounds.right;
          startY = bounds.top;
          endY = bounds.bottom;
          break;
      }
    } else {
      startX = gradientElement.getAndroidNSAttribute<double>('startX');
      startY = gradientElement.getAndroidNSAttribute<double>('startY');
      endX = gradientElement.getAndroidNSAttribute<double>('endX');
      endY = gradientElement.getAndroidNSAttribute<double>('endY');
    }
    return LinearGradient(
      colors,
      stops: stops,
      startX: startX,
      startY: startY,
      endX: endX,
      endY: endY,
      tileMode: tileMode,
    );
  } else {
    // if from a gradient drawable, `centerX/Y` is relative to the bounds
    final centerX = gradientElement
        .getAndroidNSAttribute<double>('centerX')
        ?.let((x) => isFromGradientDrawable ? x * bounds.width : x);
    final centerY = gradientElement
        .getAndroidNSAttribute<double>('centerY')
        ?.let((y) => isFromGradientDrawable ? y * bounds.height : y);
    return RadialGradient(
      colors,
      stops: stops,
      centerX: centerX,
      centerY: centerY,
      radius: gradientElement.getAndroidNSAttribute<double>('gradientRadius'),
      tileMode: tileMode,
    );
  }
}

Iterable<Tuple2<double, int>> _parseGradientColorStops(
  XmlElement gradientElement,
) {
  final childElements = gradientElement.findElements('item');
  final lastIndex = childElements.length - 1;
  if (lastIndex >= 0) {
    return childElements.mapIndexed((index, item) {
      final offset = item.getAndroidNSAttribute<double>('offset') ??
          index / (lastIndex > 0 ? lastIndex : 1);
      final color =
          item.getAndroidNSAttribute<Gradient>('color')?.colors.singleOrNull;
      return color != null ? Tuple2(offset, color) : null;
    }).whereNotNull();
  } else {
    return gradientElement.androidNSAttributes
        .where((attr) => attr.name.local.endsWith('Color'))
        .map((attr) {
      final colorInt =
          parseAndroidResourceValue<Gradient>(attr)?.colors.singleOrNull;
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
