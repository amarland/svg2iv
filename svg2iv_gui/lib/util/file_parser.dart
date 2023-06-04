import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:svg2iv_common/parser.dart';
import '../outer_world/log_file.dart';

Stream<ImageVector?> parseFiles(List<String> paths) async* {
  for (final path in paths) {
    final (imageVector, errorMessages) = await compute(
      parseXmlFile,
      (File(path), SourceDefinitionType.explicit),
    );
    await writeErrorMessages(errorMessages);
    yield imageVector;
  }
}
