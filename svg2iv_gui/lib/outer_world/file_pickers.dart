import 'dart:convert';
import 'dart:io';

import 'package:svg2iv_common/extensions.dart';

Future<List<String>?> openFileSelectionDialog() async {
  if (Platform.isWindows) {
    return await _readPowerShellCommandOutputLines(r'''
Add-Type -AssemblyName System.Windows.Forms;
$filter = "SVG files (*.svg)|*.svg|XML files (*.xml)|*.xml|All files (*.*)|*.*";
$dialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    Filter = $filter;
    Multiselect = $true;
};
if ($dialog.ShowDialog() -eq [Windows.Forms.DialogResult]::OK) {
    Write-Output $dialog.FileNames;
};''');
  } else if (Platform.isMacOS) {
    final files = await _readShellCommandOutputLines(
      'osascript -e "choose file of type'
      ' { "*.svg", "*.xml" } with multiple selections allowed"',
    );
    if (files.isNullOrEmpty) return files;
    if (files!.length > 1) return null;
    return files.single
        .split(', ')
        .takeIf((paths) => paths.isEmpty)
        ?.map((path) => path
            .split(':')
            .skip(1) // "alias Macintosh HD"
            .join(r'\'))
        .toNonGrowableList();
  } else {
    return await _readShellCommandOutputLines(
      'zenity --file-selection --file-filter="*.svg *.xml"'
      ' --multiple --separator :',
    );
  }
}

Future<String?> openDirectorySelectionDialog() async {
  if (Platform.isWindows) {
    final lines = await _readPowerShellCommandOutputLines(r'''
Add-Type -AssemblyName System.Windows.Forms;
$dialog = New-Object System.Windows.Forms.FolderBrowserDialog;
if ($dialog.ShowDialog() -eq [Windows.Forms.DialogResult]::OK) {
    Write-Output $dialog.SelectedPath;
};''');
    if (lines == null || lines.length != 1 || lines[0].isEmpty) return null;
    return lines[0];
  } else if (Platform.isMacOS) {
    final lines = await _readShellCommandOutputLines(
      'osascript -e "choose directory"',
    );
    if (lines == null || lines.length != 1) return null;
    final path = lines[0]
        .split(':')
        .skip(1) // "alias Macintosh HD"
        .join(r'\');
    return path.isNotEmpty ? path : null;
  } else {
    final lines = await _readShellCommandOutputLines(
      'zenity --file-selection --directory',
    );
    if (lines == null || lines.length != 1 || lines[0].isEmpty) return null;
    return lines[0];
  }
}

Future<List<String>?> _readPowerShellCommandOutputLines(String script) async {
  final command = script.replaceAll('\n', ' ').replaceAll(RegExp(' {2,}'), ' ');
  return _readOutputLines(
    await Process.run(
      'powershell',
      ['Invoke-Expression', '-Command', "'$command'"],
    ),
  );
}

Future<List<String>?> _readShellCommandOutputLines(String command) async =>
    _readOutputLines(await Process.run('sh', ['-c', command]));

/* file selected                      -> non-empty list
 * file not selected but dialog shown -> empty list
 * dialog not shown                   -> null
 */
List<String>? _readOutputLines(ProcessResult processResult) =>
    (processResult.stdout as String)
        .takeIf((_) => processResult.exitCode == 0)
        ?.let((result) => const LineSplitter().convert(result)
          ..removeWhere((it) => it.isNullOrEmpty));
