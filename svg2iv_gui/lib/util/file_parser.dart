import 'dart:io';
import 'dart:isolate';

import 'package:svg2iv_common/parser.dart';

import '../outer_world/log_file.dart';

Future<List<ImageVector?>> parseFiles(List<String> paths) async {
  if (paths.isEmpty) return List.empty();
  final (imageVectors, errorMessages) = await Isolate.run(
    () {
      final imageVectors = <ImageVector?>[];
      final errorMessages = <String>[];
      for (final path in paths) {
        final (imageVector, messages) = parseXmlFile(
          File(path),
          SourceDefinitionType.explicit,
        );
        imageVectors.add(imageVector);
        errorMessages.addAll(messages);
      }
      return (imageVectors, errorMessages);
    },
  );
  await writeErrorMessages(errorMessages);
  return imageVectors;
}
