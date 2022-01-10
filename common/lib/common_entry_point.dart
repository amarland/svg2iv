import 'dart:io';

import 'package:tuple/tuple.dart';
import 'package:xml/xml.dart';

import 'file_parser.dart';
import 'model/image_vector.dart';
import 'svg2iv.dart';
import 'vd2iv.dart';

Tuple2<List<ImageVector?>, List<String>> parseFiles(List<File> files) {
  if (files.isEmpty) return Tuple2(List.empty(), List.empty());

  final imageVectors = <ImageVector?>[];
  final errorMessages = <String>[];
  for (final file in files) {
    // TODO: redundant?
    if (!file.existsSync()) {
      errorMessages.add('${file.path} does not exist!');
    }
    try {
      final result = file.path.endsWith('.svg')
          ? parseSvgFile(file)
          : parseVectorDrawableFile(file);
      imageVectors.add(result);
    } on FileParserException catch (e) {
      errorMessages
        ..add('An error occurred while parsing ${file.path}:')
        ..add(e.message);
    } catch (e) {
      errorMessages
        ..add('An unexpected error occurred while parsing ${file.path}:')
        ..add(e.runtimeType.toString());
      if (e is Error) {
        errorMessages.add(e.stackTrace.toString());
      } else if (e is XmlException) {
        errorMessages.add(e.message);
      }
    }
  }
  return Tuple2(imageVectors, errorMessages);
}
