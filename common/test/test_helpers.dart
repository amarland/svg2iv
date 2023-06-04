import 'dart:io';

(String, String) executeKotlinScript(String source) {
  final tempDirectoryPath = Directory.systemTemp.path.replaceAll('\\', '/');
  final scriptSourceFile = File('$tempDirectoryPath/test_script.main.kts')
    ..createSync()
    ..writeAsStringSync(source, flush: true);
  final executableName = 'kotlin';
  final arguments = ['-howtorun', 'script', scriptSourceFile.path];
  final isPlatformWindows = Platform.isWindows;
  // on Windows, the actual executable is 'powershell.exe',
  // so the first argument has to be `executableName`
  if (isPlatformWindows) {
    arguments.insert(0, '$executableName.bat');
  }
  try {
    final result = Process.runSync(
      isPlatformWindows ? 'powershell' : executableName,
      arguments,
    );
    return (result.stdout as String, result.stderr as String);
  } finally {
    scriptSourceFile.deleteSync();
  }
}
