import 'dart:io' show File, FileSystemException;

import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

import 'converter/gd2iv.dart';
import 'converter/svg2iv.dart';
import 'converter/vd2iv.dart';
import 'model/image_vector.dart';

typedef ParseResult = (ImageVector?, List<String> errorMessages);
typedef ParseSource = (File, SourceDefinitionType);

enum SourceDefinitionType { explicit, implicit }

ParseResult parseXmlFile((File, SourceDefinitionType) source) {
  final (file, definitionType) = source;
  return _parseXmlSource(
    file,
    isSourceDefinedExplicitly: definitionType == SourceDefinitionType.explicit,
  );
}

ParseResult parseXmlString(String source) =>
    _parseXmlSource(source, isSourceDefinedExplicitly: true);

ParseResult _parseXmlSource(
  dynamic source, {
  required bool isSourceDefinedExplicitly,
}) {
  final isSourceAFile = source is File;
  if (!isSourceAFile && source is! String) {
    throw UnsupportedError(
      'The source must be either a `File` or a `String`!',
    );
  }
  ImageVector? imageVector;
  final errorMessages = <String>[];
  try {
    final sourceAsString =
        isSourceAFile ? source.readAsStringSync() : source as String;
    final rootElementName = parseEvents(sourceAsString)
        .whereType<XmlStartElementEvent>()
        .firstOrNull
        ?.name;
    switch (rootElementName) {
      case 'svg':
        imageVector = parseSvgElement(sourceAsString);
        break;
      case 'vector':
        imageVector = parseVectorDrawableElement(
          _parseXmlString(sourceAsString),
        );
        break;
      case 'shape':
        imageVector = parseShapeDrawableElement(
          _parseXmlString(sourceAsString),
        );
        break;
      default:
        if (isSourceDefinedExplicitly) {
          errorMessages.add(
            '${isSourceAFile ? "'${source.path}': " : ''}Unsupported format',
          );
        }
        break;
    }
  } on FileSystemException {
    errorMessages.add('The file could not be read.');
  } on ParserException catch (e) {
    final messageBuilder = StringBuffer('An error occurred while parsing ')
      ..write(isSourceAFile ? "'${source.path}'" : 'the input string')
      ..write(':');
    errorMessages
      ..add(messageBuilder.toString())
      ..add(e.message);
  } catch (e) {
    final messageBuilder =
        StringBuffer('An unexpected error occurred while parsing ')
          ..write(source is File ? "'${source.path}'" : 'the input string')
          ..write(':')
          ..write(e.runtimeType);
    errorMessages.add(messageBuilder.toString());
    if (e is Error) {
      errorMessages.add(e.stackTrace.toString());
    } else if (e is XmlException) {
      errorMessages.add(e.message);
    }
  }
  return (imageVector, errorMessages);
}

XmlElement _parseXmlString(String source) {
  final XmlDocument document;
  try {
    document = XmlDocument.parse(source);
  } on XmlParserException {
    throw ParserException('The contents of the file could not be parsed.');
  }
  final XmlElement rootElement;
  try {
    rootElement = document.rootElement;
  } on StateError {
    throw ParserException('The file is empty.');
  }
  return rootElement;
}

class ParserException extends FormatException {
  const ParserException(String message) : super(message);
}
