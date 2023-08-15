import 'dart:io' show File, FileSystemException;

import 'package:xml/xml.dart';

import 'converter/gd2iv.dart';
import 'converter/svg2iv.dart';
import 'converter/vd2iv.dart';
import 'extensions.dart';
import 'model/image_vector.dart';

typedef ParseResult = (ImageVector?, List<String> errorMessages);

enum SourceDefinitionType { explicit, implicit }

ParseResult parseXmlFile(File file, SourceDefinitionType definitionType) {
  return _parseXmlSource(
    file.readAsStringSync(),
    isSourceDefinedExplicitly: definitionType == SourceDefinitionType.explicit,
  );
}

ParseResult parseXmlString(String source, {String? sourcePath}) {
  return _parseXmlSource(
    source,
    isSourceDefinedExplicitly: true,
    sourcePath: sourcePath,
  );
}

ParseResult _parseXmlSource(
  String source, {
  required bool isSourceDefinedExplicitly,
  String? sourcePath,
}) {
  final hasPath = sourcePath != null && sourcePath.isNotEmpty;
  ImageVector? imageVector;
  final errorMessages = <String>[];
  const errorMessageIndent = '  ';
  try {
    final rootElement = _parseXmlString(source);
    final imageVectorName = hasPath
        ? sourcePath.substring(
            sourcePath.lastIndexOf(r'[/\]') + 1,
            sourcePath.lastIndexOfOrNull('.'),
          )
        : null;
    final rootElementName = rootElement.name.local;
    switch (rootElementName) {
      case 'svg':
        imageVector = parseSvgElement(
          rootElement,
          imageVectorName: imageVectorName,
        );
        break;
      case 'vector':
        imageVector = parseVectorDrawableElement(
          rootElement,
          imageVectorName: imageVectorName,
        );
        break;
      case 'shape':
        imageVector = parseShapeDrawableElement(
          rootElement,
          imageVectorName: imageVectorName,
        );
        break;
      default:
        if (isSourceDefinedExplicitly) {
          final messageBuilder = StringBuffer();
          if (hasPath) {
            messageBuilder.write("'$sourcePath': ");
          }
          messageBuilder.write("Unsupported XML root: '$rootElementName'");
          errorMessages.add(messageBuilder.toString());
        }
        break;
    }
  } on ParserException catch (e) {
    final messageBuilder = StringBuffer('An error occurred while parsing ')
      ..write(hasPath ? "'$sourcePath'" : 'the input string')
      ..write(':');
    errorMessages
      ..add(messageBuilder.toString())
      ..add('$errorMessageIndent${e.message}');
  } catch (e) {
    final messageBuilder =
        StringBuffer('An unexpected error occurred while parsing ')
          ..write(hasPath ? "'$sourcePath'" : 'the input string')
          ..writeln(':')
          ..writeln('$errorMessageIndent${e.runtimeType}');
    errorMessages.add(messageBuilder.toString());
    if (e is Error) {
      errorMessages.add(
        e.stackTrace.toString().replaceAll('\n', '\n$errorMessageIndent'),
      );
    } else if (e is XmlException) {
      errorMessages.add('$errorMessageIndent${e.message}');
    }
  }
  return (imageVector, errorMessages);
}

XmlElement _parseXmlString(String source) {
  final XmlDocument document;
  try {
    document = XmlDocument.parse(source);
  } on FileSystemException {
    throw ParserException('The input file could not be read.');
  } on XmlParserException {
    throw ParserException('The input is not valid XML.');
  }
  final XmlElement rootElement;
  try {
    rootElement = document.rootElement;
  } on StateError {
    throw ParserException('The input is empty.');
  }
  return rootElement;
}

class ParserException extends FormatException {
  const ParserException(String message) : super(message);
}
