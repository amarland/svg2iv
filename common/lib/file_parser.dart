import 'dart:io' show File, FileSystemException;

import 'package:tuple/tuple.dart' show Tuple2;
import 'package:xml/xml.dart';

import 'gd2iv.dart';
import 'model/image_vector.dart';
import 'svg2iv.dart';
import 'vd2iv.dart';

enum SourceFileDefinitionType { explicit, implicit }

Tuple2<List<ImageVector?>, List<String>> parseFiles(
  List<Tuple2<File, SourceFileDefinitionType>> files,
) {
  if (files.isEmpty) return Tuple2(List.empty(), List.empty());

  final imageVectors = <ImageVector?>[];
  final errorMessages = <String>[];
  for (final pair in files) {
    final file = pair.item1;
    final isFileDefinedExplicitly =
        pair.item2 == SourceFileDefinitionType.explicit;
    try {
      final rootElement = _parseXmlFile(file);
      final rootElementName = rootElement.name.local;
      switch (rootElementName) {
        case 'svg':
          imageVectors.add(parseSvgElement(rootElement));
          break;
        case 'vector':
          imageVectors.add(parseVectorDrawableElement(rootElement));
          break;
        case 'shape':
          imageVectors.add(parseShapeDrawableElement(rootElement));
          break;
        default:
          if (isFileDefinedExplicitly) {
            errorMessages.add(
              "'${file.path}': unsupported XML root: '$rootElementName'",
            );
          }
          break;
      }
    } on FileParserException catch (e) {
      errorMessages
        ..add("An error occurred while parsing '${file.path}':")
        ..add(e.message);
    } catch (e) {
      errorMessages.add(
        "An unexpected error occurred while parsing '${file.path}': " +
            e.runtimeType.toString(),
      );
      if (e is Error) {
        errorMessages.add(e.stackTrace.toString());
      } else if (e is XmlException) {
        errorMessages.add(e.message);
      }
    }
  }
  return Tuple2(imageVectors, errorMessages);
}

XmlElement _parseXmlFile(File source) {
  final XmlDocument document;
  try {
    document = XmlDocument.parse(source.readAsStringSync());
  } on FileSystemException {
    throw FileParserException('The file could not be read.');
  } on XmlParserException {
    throw FileParserException('The contents of the file could not be parsed.');
  }
  final XmlElement rootElement;
  try {
    rootElement = document.rootElement;
  } on StateError {
    throw FileParserException('The file is empty.');
  }
  return rootElement;
}

class FileParserException extends FormatException {
  const FileParserException(String message) : super(message);
}
