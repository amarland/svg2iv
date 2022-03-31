import 'dart:io';

import 'package:tuple/tuple.dart';

Tuple2<String, String> executeKotlinScript(String source) {
  final tempDirectoryPath = Directory.systemTemp.path;
  final scriptSourceFile = File(tempDirectoryPath + '/test_script.main.kts')
    ..createSync()
    ..writeAsStringSync(
      source,
      flush: true,
    );
  final workingDirectory = Directory('$tempDirectoryPath/kotlinc');
  final workingDirectoryPath = workingDirectory.path.replaceAll('\\', '/');
  if (!workingDirectory.existsSync() ||
      workingDirectory
          .listSync()
          .where((e) => e is Directory || e is File)
          .isEmpty) {
    final compilerArchiveFile = Directory('test_tool').listSync().singleWhere(
      (e) {
        // ignore: unnecessary_string_escapes
        final fileNameRegExp = RegExp('''kotlin-compiler-.{3,6}\.zip''');
        return fileNameRegExp.allMatches(e.path).length == 1;
      },
      orElse: () => throw 'The archive file containing the Kotlin compiler'
          ' could not be found!',
    ) as File;
    Process.runSync(
      'tar',
      ['-xf', compilerArchiveFile.absolute.path],
      workingDirectory: tempDirectoryPath,
    );
  }
  final executable = '$workingDirectoryPath/bin/kotlinc';
  // use PowerShell on Windows as it understands slashes as path separators
  try {
    final arguments = [
      '-cp',
      '$workingDirectoryPath/lib/kotlin-main-kts.jar',
      '-script',
      scriptSourceFile.path,
    ];
    // on Windows, the actual executable is 'powershell.exe',
    // so the first argument has to be 'kotlinc.bat'
    if (Platform.isWindows) {
      arguments.insert(0, '$executable.bat');
    }
    final result = Process.runSync(
      Platform.isWindows ? 'powershell' : executable,
      arguments,
    );
    return Tuple2(result.stdout as String, result.stderr as String);
  } finally {
    scriptSourceFile.deleteSync();
  }
}
