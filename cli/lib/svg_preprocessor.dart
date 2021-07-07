import 'package:collection/collection.dart';
import 'package:svg2iv/svg2iv.dart';
import 'package:svg2iv_common/extensions.dart';
import 'package:xml/xml.dart';

const useElementCustomAttributePrefix = 'use_';

void preprocessSvg(XmlElement svgElement) {
  _moveDefsElementToFirstPositionIfAny(svgElement);
  _inlineUseElements(svgElement);
  _reorderClipPathElementsIfNeeded(svgElement);
  _convertCssStyleAttributesToSvgPresentationAttributes(svgElement);
}

void _moveDefsElementToFirstPositionIfAny(XmlElement svgElement) {
  final defsElement = svgElement.getElement('defs');
  if (defsElement != null &&
      // if it's not the first child of its parent
      !identical(defsElement.parent!.children[0], defsElement)) {
    defsElement.parent!.children.remove(defsElement);
    svgElement.children.insert(0, defsElement);
  }
}

void _inlineUseElements(XmlElement svgElement) {
  for (final useElement in svgElement.findAllElements('use')) {
    final referencedElementId = useElement.attributes
        .where((attr) => attr.name.local.replaceFirst('xlink:', '') == 'href')
        .singleOrNull
        ?.value
        .substring(1); // [0] => #
    if (referencedElementId != null &&
        referencedElementId != (useElement.getAttribute('id') ?? '')) {
      final referencedElement = svgElement.descendants
          .whereType<XmlElement>()
          .where((d) {
            final id = d.getAttribute('id');
            return id != null && id == referencedElementId;
          })
          .singleOrNull
          ?.copy();
      if (referencedElement != null) {
        for (final attributeName in ['x', 'y']) {
          final attributeValue = useElement.getAttribute(attributeName);
          if (attributeValue.isNullOrEmpty) continue;
          final attributeValueAsDouble = attributeValue!.toDouble();
          if (attributeValueAsDouble == null) continue;
          if (referencedElement.name.local == 'rect') {
            final existingAttributeValue = referencedElement
                    .getAttribute(attributeName)
                    ?.let(double.tryParse) ??
                0.0;
            referencedElement.setAttribute(
              attributeName,
              (attributeValueAsDouble + existingAttributeValue).toString(),
            );
          } else {
            // use custom attribute names to avoid confusion with possible
            // "illegally"-defined x/y attributes
            referencedElement.setAttribute(
              useElementCustomAttributePrefix + attributeName,
              attributeValueAsDouble.toString(),
            );
          }
        }
        referencedElement.removeAttribute('id');
        const nonInheritedAttributeNames = {
          'x',
          'y',
          'width',
          'height',
          'xlink:href',
          'href',
        };
        final inheritableAttributes = useElement.attributes.whereNot(
          (attr) => nonInheritedAttributeNames.contains(attr.name.local),
        );
        for (final useElementAttribute in inheritableAttributes) {
          final useElementAttributeName = useElementAttribute.name;
          final referencedElementAttribute = referencedElement.attributes
              .where((attr) => attr.name == useElementAttributeName)
              .singleOrNull;
          if (referencedElementAttribute == null) {
            referencedElement.setAttribute(
              useElementAttribute.name.local,
              useElementAttribute.value,
              namespace: useElementAttribute.name.namespaceUri,
            );
          }
        }
        useElement.replace(referencedElement);
      } else {
        useElement.parentElement!.children.remove(useElement);
      }
    }
  }
}

/*
void _wrapClippedPathsIntoGroups(XmlElement svgElement) {
  final allNonGroupChildElements = svgElement.descendants
      .whereType<XmlElement>()
      .where((element) => element.name.local != 'g');
  for (final element in allNonGroupChildElements) {
    final clipPathAttribute = element.attributes
        .singleWhereOrNull((attr) => attr.name.local == 'clip-path');
    if (clipPathAttribute != null) {
      element.replace(
        XmlElement(
          XmlName('g'),
          [clipPathAttribute],
          [element..attributes.remove(clipPathAttribute)],
        ),
      );
    }
  }
}
*/

void _reorderClipPathElementsIfNeeded(XmlElement svgElement) {
  for (final clipPathElement in svgElement.findAllElements('clipPath')) {
    final defsElement = _getOrCreateDefsElement(svgElement);
    final clipPathElementIdNode = clipPathElement.getAttributeNode('id');
    final clipPathElementId = clipPathElementIdNode?.value;
    if (clipPathElementId.isNullOrEmpty) continue;
    final parentElement = clipPathElement.parentElement!;
    parentElement.children.remove(clipPathElement);

    XmlElement _nestReferencedClipPathElementIfAny(XmlElement clipPathElement) {
      final childElement = clipPathElement.firstElementChild;
      final childClipPathAttribute = childElement?.attributes
          .singleWhereOrNull((attr) => attr.name.local == 'clip-path');
      if (childClipPathAttribute != null) {
        clipPathElement.attributes.remove(clipPathElementIdNode);
        childElement!.attributes.remove(childClipPathAttribute);
        final referencedElementId = extractIdFromUrlFunctionCall(
          childClipPathAttribute.value,
        );
        final referencedElement =
            defsElement.children.whereType<XmlElement>().where((element) {
          final id = element.getAttribute('id');
          return id != null && id == referencedElementId;
        }).singleOrNull;
        if (referencedElement != null) {
          return _nestReferencedClipPathElementIfAny(
            referencedElement.copy()
              ..removeAttribute('id')
              ..children.add(clipPathElement),
          );
        }
      }
      return clipPathElement;
    }

    defsElement.children.add(
      _nestReferencedClipPathElementIfAny(clipPathElement)
        ..setAttribute('id', clipPathElementId),
    );
  }
}

XmlElement _getOrCreateDefsElement(XmlElement svgElement) =>
    svgElement.getElement('defs') ??
    XmlElement(XmlName('defs')).also((e) => svgElement.children.insert(0, e));

void _convertCssStyleAttributesToSvgPresentationAttributes(
    XmlElement svgElement) {
  for (final element in svgElement.children.whereType<XmlElement>()) {
    final styleAttributeNode = element.getAttributeNode('style');
    final styleAttributeValues = styleAttributeNode?.value
        .split(RegExp(r';\s*'))
        .takeIf((it) => it.isNotEmpty);
    if (styleAttributeValues != null) {
      element.attributes.remove(styleAttributeNode);
      for (final keyValuePairAsString in styleAttributeValues) {
        final keyValuePair = keyValuePairAsString.split(RegExp(r':\s*'));
        if (keyValuePair.length == 2) {
          element.attributes.add(
            XmlAttribute(XmlName(keyValuePair[0]), keyValuePair[1]),
          );
        }
      }
    }
  }
}
