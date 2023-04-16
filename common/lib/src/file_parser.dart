import 'dart:io' show File, FileSystemException;

import 'package:svg2iv_common/extensions.dart';
import 'package:tuple/tuple.dart' show Tuple2;
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

import 'converter/gd2iv.dart';
import 'converter/svg2iv.dart';
import 'converter/vd2iv.dart';
import 'model/image_vector.dart';

enum SourceDefinitionType { explicit, implicit }

Tuple2<ImageVector?, List<String>> parseXmlFile(
  Tuple2<File, SourceDefinitionType> file,
) {
  final result = _parseXmlSource(
    file.item1,
    isSourceDefinedExplicitly: file.item2 == SourceDefinitionType.explicit,
  );
  return Tuple2(result.item1, result.item2);
}

Tuple2<ImageVector?, List<String>> parseXmlString(String source) =>
    _parseXmlSource(source, isSourceDefinedExplicitly: true);

Tuple2<ImageVector?, List<String>> _parseXmlSource(
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
  return Tuple2(imageVector, errorMessages);
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
