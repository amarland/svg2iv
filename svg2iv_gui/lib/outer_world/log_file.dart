import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:tuple/tuple.dart';

import '../util/exception_handlers.dart';

Future<String> get _filePath async {
  return path.join(
    (await path_provider.getApplicationSupportDirectory()).path,
    'svg2iv.log',
  );
}

Future<void> writeErrorMessages(List<String> messages) async {
  return runIgnoringException<FileSystemException>(() async {
    final sink = File(await _filePath).openWrite();
    sink.writeAll(messages, '\n');
    await sink.flush();
    await sink.close();
  });
}

Future<Tuple2<List<String>, bool>> readErrorMessages(int limit) async {
  List<String>? messages;
  var hasMoreThanLimit = false;
  final file = File(await _filePath);
  await runIgnoringException<FileSystemException>(() async {
    if (await file.exists()) {
      final amountToTake = limit + 1;
      final lines = await file
          .openRead()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .take(amountToTake)
          .toList();
      hasMoreThanLimit = lines.length == amountToTake;
      messages = hasMoreThanLimit ? lines.slice(0, limit) : lines;
    }
  });
  return Tuple2(messages ?? List.empty(), hasMoreThanLimit);
}

Future<void> openLogFileInPreferredApplication() async {
  final String executable;
  final isPlatformWindows = Platform.isWindows;
  if (isPlatformWindows) {
    executable = 'powershell';
  } else if (Platform.isMacOS) {
    executable = 'open';
  } else {
    executable = 'xdg-open';
  }
  final filePath = await _filePath;
  final arguments = List<String>.generate(isPlatformWindows ? 3 : 1, (index) {
    switch (index) {
      case 0:
        return isPlatformWindows
            ? 'Start-Process'
            : filePath.replaceAll(' ', '\\ ');
      case 1: // is Windows
        return '-FilePath';
      default: // == case 2; is Windows
        return '"$filePath"';
    }
  });
  await Process.run(executable, arguments);
}
