import 'dart:io' show File, FileSystemException;

import 'package:tuple/tuple.dart' show Tuple2;
import 'package:xml/xml.dart';

import 'converter/gd2iv.dart';
import 'converter/svg2iv.dart';
import 'converter/vd2iv.dart';
import 'model/image_vector.dart';

enum SourceDefinitionType { explicit, implicit }

Tuple2<ImageVector?, List<String>> parseXmlFile(
  Tuple2<File, SourceDefinitionType> file, {
  bool normalizePaths = false,
}) {
  final result = _parseXmlSource(
    file.item1,
    isSourceDefinedExplicitly: file.item2 == SourceDefinitionType.explicit,
    normalizePaths: normalizePaths,
  );
  return Tuple2(result.item1, result.item2);
}

Tuple2<ImageVector?, List<String>> parseXmlString(
  String source, {
  bool normalizePaths = false,
}) {
  return _parseXmlSource(
    source,
    isSourceDefinedExplicitly: true,
    normalizePaths: normalizePaths,
  );
}

Tuple2<ImageVector?, List<String>> _parseXmlSource(
  dynamic source, {
  required bool isSourceDefinedExplicitly,
  bool normalizePaths = false,
}) {
  final isSourceAFile = source is File;
  if (!isSourceAFile && source is! String) {
    throw UnsupportedError(
      'The source must be either a `File` or a `String`!',
    );
  }
  ImageVector? imageVector;
  final errorMessages = List<String>.empty(growable: true);
  try {
    final rootElement = _parseXmlString(
      isSourceAFile ? source.readAsStringSync() : source as String,
    );
    final rootElementName = rootElement.name.local;
    switch (rootElementName) {
      case 'svg':
        imageVector = parseSvgElement(
          rootElement,
          normalizePaths: normalizePaths,
        );
        break;
      case 'vector':
        imageVector = parseVectorDrawableElement(
          rootElement,
          normalizePaths: normalizePaths,
        );
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
  return Tuple2(imageVector, errorMessages);
}

XmlElement _parseXmlString(String source) {
  final XmlDocument document;
  try {
    document = XmlDocument.parse(source);
  } on FileSystemException {
    throw ParserException('The file could not be read.');
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
