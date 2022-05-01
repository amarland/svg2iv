import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:svg2iv_common/parser.dart';
import '../outer_world/log_file.dart';

Stream<ImageVector?> parseFiles(List<String> paths) async* {
  for (final path in paths) {
    final parseResult = await compute(
      parseXmlFile,
      Tuple2(File(path), SourceDefinitionType.explicit),
    );
    final imageVector = parseResult.item1;
    final errorMessages = parseResult.item2;
    await writeErrorMessages(errorMessages);
    yield imageVector;
  }
}
