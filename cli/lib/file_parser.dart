import 'dart:io';

import 'package:xml/xml.dart';

XmlElement parseXmlFile(File source, {String? expectedRootName}) {
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
    if (expectedRootName != null &&
        rootElement.name.local != expectedRootName) {
      throw FileParserException(
        'The root element is not a `$expectedRootName` element.',
      );
    }
  } on StateError {
    throw FileParserException('The file is empty.');
  }
  return rootElement;
}

class FileParserException extends FormatException {
  const FileParserException(String message) : super(message);
}
