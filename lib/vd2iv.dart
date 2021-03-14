import 'dart:io';

import 'package:svg2iv/extensions.dart';
import 'package:svg2iv/file_parser.dart';
import 'package:svg2iv/model/image_vector.dart';
import 'package:svg2iv/model/vector_group.dart';
import 'package:svg2iv/model/vector_node.dart';
import 'package:xml/xml.dart';

const _androidNamespaceUri = 'http://schemas.android.com/apk/res/android';

ImageVector parseSvgFile(File source) {
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
    }
  }
  return builder.build();
}

// can be a single group or the list of its nodes if it's considered "redundant"
Iterable<VectorNode> _parseGroupElement(XmlElement groupElement) {
  final groupBuilder = VectorGroupBuilder();
  groupElement
      .getAndroidNSAttribute('name')
      ?.let((name) => groupBuilder.id(name));
  // TODO
  final group = groupBuilder.build();
  return group.hasAttributes ? [group] : group.nodes;
}

extension AndroidNSAttributeParsing on XmlElement {
  String? getAndroidNSAttribute(String name) =>
      getAttribute(name, namespace: _androidNamespaceUri);

  Iterable<XmlAttribute> get androidNSAttributes => attributes
      .where((attr) => attr.name.namespaceUri == _androidNamespaceUri);
}
