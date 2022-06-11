import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import '../converter/svg2iv.dart';
import '../extensions.dart';

const useElementCustomAttributePrefix = 'use_';

@internal
void preprocessSvg(XmlElement svgElement) {
  _moveDefsElementToFirstPositionIfAny(svgElement);
  _inlineUseElements(svgElement);
  _reorderClipPathElementsIfNeeded(svgElement);
  _convertInlineCssStylesToSvgPresentationAttributes(svgElement);
  _convertCssStylesheetToSvgPresentationAttributes(svgElement);
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
            referencedElement.attributes.add(
              XmlAttribute(
                useElementAttribute.name.copy(),
                useElementAttribute.value,
              ),
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
        final referencedElement = defsElement.childElements.where((element) {
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

void _convertInlineCssStylesToSvgPresentationAttributes(XmlElement svgElement) {
  for (final element in svgElement.childElements) {
    final styleAttributeNode = element.getAttributeNode('style');
    final styleAttributeValues = styleAttributeNode?.value
        .split(RegExp(r';\s*'))
        .takeIf((it) => it.isNotEmpty);
    if (styleAttributeValues != null) {
      final attributes = element.attributes;
      attributes.remove(styleAttributeNode);
      for (final nameValuePairAsString in styleAttributeValues) {
        final nameValuePair = nameValuePairAsString.split(RegExp(r'\s*:\s*'));
        if (nameValuePair.length == 2) {
          attributes.add(
            XmlAttribute(XmlName(nameValuePair[0]), nameValuePair[1]),
          );
        }
      }
    }
  }
}

void _convertCssStylesheetToSvgPresentationAttributes(XmlElement svgElement) {
  XmlElement? findSingleStyleElement(XmlElement e) =>
      e.childElements.where((e) => e.name.local == 'style').singleOrNull;
  final styleElement = findSingleStyleElement(svgElement) ??
      svgElement.getElement('defs')?.let(findSingleStyleElement);
  if (styleElement != null) {
    styleElement.parentElement!.children.remove(styleElement);
    final declarationBlocks = styleElement.text
        .replaceAll(RegExp(r'\s'), '')
        .split('}')
      ..removeWhere((block) => block.isEmpty)
      ..sort((block1, block2) => _getSpecificityForSelector(block1)
          .compareTo(_getSpecificityForSelector(block2)));
    final attributesToKeep = HashSet<XmlAttribute>.identity();
    declarationBlocks.forEachIndexed((declarationBlockIndex, declarationBlock) {
      final declarationBlockParts = declarationBlock.split('{');
      if (declarationBlockParts.length != 2) {
        return;
      }
      // continue if there's only one selector
      if (declarationBlockParts[0].contains(',')) {
        return;
      }
      final targetElements = svgElement.descendantElements.where((e) {
        final selector = declarationBlockParts[0];
        switch (selector[0]) {
          case '*':
            return selector.length == 1;
          case '#':
            return selector.substring(1) == e.getAttribute('id');
          case '.':
            return selector.substring(1) == e.getAttribute('class');
          default:
            return selector == e.name.local;
        }
      });
      if (targetElements.isEmpty) {
        return;
      }
      final splitDeclarations = declarationBlockParts[1]
          .split(';')
          .where((s) => s.isNotEmpty)
          .map((s) => s.split(':').takeIf((list) => list.length == 2))
          .whereNotNull();
      for (final nameValuePair in splitDeclarations) {
        for (final targetElement in targetElements) {
          final name = nameValuePair[0];
          final value = nameValuePair[1];
          final attributes = targetElement.attributes;
          final existingAttributeIndex =
              attributes.indexWhere((a) => a.name.local == name);
          if (existingAttributeIndex >= 0) {
            final existingAttribute = attributes[existingAttributeIndex];
            if (declarationBlockIndex == 0) {
              // this is the first "pass", which means the existing attribute
              // has the highest specificity;
              // keep a reference to it so it's not overridden
              attributesToKeep.add(existingAttribute);
            } else {
              // for subsequent "passes", if the existing attribute
              // isn't one that was previously saved, this means it has a lower
              // specificity since the blocks are sorted; replace it
              if (!attributesToKeep.contains(existingAttribute)) {
                attributes[existingAttributeIndex] =
                    XmlAttribute(XmlName(name), value);
              }
            }
          } else {
            attributes.add(XmlAttribute(XmlName(name), value));
          }
        }
      }
    });
  }
}

int _getSpecificityForSelector(String declarationBlock) {
  final int specificity;
  switch (declarationBlock[0]) {
    case '*':
      specificity = 0;
      break;
    case '.':
      specificity = 2;
      break;
    case '#':
      specificity = 3;
      break;
    default:
      specificity = 1;
      break;
  }
  return specificity;
}
