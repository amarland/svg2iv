import 'dart:io' show File, FileSystemException;

import 'package:xml/xml.dart';

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
  final errorMessages = List<String>.empty(growable: true);
  const errorMessageIndent = '  ';
  try {
    final rootElement = _parseXmlString(
      isSourceAFile ? source.readAsStringSync() : source as String,
    );
    final rootElementName = rootElement.name.local;
    switch (rootElementName) {
      case 'svg':
        imageVector = parseSvgElement(rootElement);
        break;
      case 'vector':
        imageVector = parseVectorDrawableElement(rootElement);
        break;
      case 'shape':
        imageVector = parseShapeDrawableElement(rootElement);
        break;
      default:
        if (isSourceDefinedExplicitly) {
          final messageBuilder = StringBuffer();
          if (isSourceAFile) {
            messageBuilder.write("'${source.path}': ");
          }
          messageBuilder.write("Unsupported XML root: '$rootElementName'");
          errorMessages.add(messageBuilder.toString());
        }
        break;
    }
  } on ParserException catch (e) {
    final messageBuilder = StringBuffer('An error occurred while parsing ')
      ..write(source is File ? "'${source.path}'" : 'the input string')
      ..write(':');
    errorMessages
      ..add(messageBuilder.toString())
      ..add('$errorMessageIndent${e.message}');
  } catch (e) {
    final messageBuilder =
        StringBuffer('An unexpected error occurred while parsing ')
          ..write(source is File ? "'${source.path}'" : 'the input string')
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
