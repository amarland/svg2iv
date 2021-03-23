import 'package:collection/collection.dart';
import 'package:svg2iv/extensions.dart';
import 'package:svg2iv/svg2iv.dart';
import 'package:xml/xml.dart';

const useElementCustomAttributePrefix = 'use_';

void preprocessSvg(XmlElement svgElement) {
  _moveDefsElementToFirstPositionIfAny(svgElement);
  _inlineUseElements(svgElement);
  _reorderClipPathElementsIfNeeded(svgElement);
}

void _moveDefsElementToFirstPositionIfAny(XmlElement svgElement) {
  final defsElement = svgElement.getElement('defs');
  if (defsElement != null &&
      // if there's another element before it
      defsElement.previousSibling?.takeIf((it) => it is XmlElement) != null) {
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
    final defsElement = getOrCreateDefsElement(svgElement);
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

XmlElement getOrCreateDefsElement(XmlElement svgElement) =>
    svgElement.getElement('defs') ??
    XmlElement(XmlName('defs')).also((e) => svgElement.children.insert(0, e));
