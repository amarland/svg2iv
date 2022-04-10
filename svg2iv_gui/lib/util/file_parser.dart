import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:svg2iv_common/file_parser.dart';
import 'package:svg2iv_common/model/image_vector.dart';
import 'package:svg2iv_gui/outer_world/log_file.dart';
import 'package:tuple/tuple.dart';

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
