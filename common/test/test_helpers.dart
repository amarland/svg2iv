import 'dart:io';

import 'package:svg2iv_common/extensions.dart';
import 'package:tuple/tuple.dart';
import 'package:test/test.dart';

Tuple2<String, String> executeKotlinScript(String source) {
  final tempDirectoryPath = Directory.systemTemp.path.replaceAll('\\', '/');
  final scriptSourceFile = File('$tempDirectoryPath/test_script.main.kts')
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
        final fileNameRegExp = RegExp('''kotlin-compiler-.{3,6}\.tar.gz''');
        return fileNameRegExp.allMatches(e.path).length == 1;
      },
      orElse: () => throw 'The archive file containing the Kotlin compiler'
          ' could not be found!',
    ) as File;
    final extractionResult = Process.runSync(
      'tar',
      ['-xf', compilerArchiveFile.absolute.path],
      workingDirectory: tempDirectoryPath,
    );
    if (extractionResult.exitCode != 0) {
      fail(extractionResult.stderr as String);
    }
    // ignore: prefer_interpolation_to_compose_strings
    final extractedDirectoryPath = '$tempDirectoryPath/' +
        compilerArchiveFile.getNameWithoutExtension().replaceAll('.tar', '');
    _runProcess('mv', [
      '$extractedDirectoryPath/kotlinc',
      tempDirectoryPath,
    ]);
    _runProcess('rm', ['-r', extractedDirectoryPath]);
  }
  try {
    final arguments = [
      '-cp',
      '$workingDirectoryPath/lib/kotlin-main-kts.jar',
      '-script',
      scriptSourceFile.path,
    ];
    final executable = '$workingDirectoryPath/bin/kotlinc';
    final isPlatformWindows = Platform.isWindows;
    if (!isPlatformWindows) {
      Process.runSync('chmod', ['+x', executable]);
    }
    final result = _runProcess(
      isPlatformWindows ? '$executable.bat' : executable,
      arguments,
    );
    return Tuple2(result.stdout as String, result.stderr as String);
  } finally {
    scriptSourceFile.deleteSync();
    _runProcess('rm', ['-r', workingDirectoryPath]);
  }
}

ProcessResult _runProcess(String executable, List<String> arguments) {
  final isPlatformWindows = Platform.isWindows;
  // on Windows, the actual executable is 'powershell.exe',
  // so the first argument has to be `executable`
  if (isPlatformWindows) {
    arguments.insert(0, executable);
  }
  return Process.runSync(
    isPlatformWindows ? 'powershell' : executable,
    arguments,
  );
}
