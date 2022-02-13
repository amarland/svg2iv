import 'dart:io';

import 'package:args/args.dart';
import 'package:svg2iv/image_vector_transmitter.dart';
import 'package:svg2iv_common/file_parser.dart';
import 'package:svg2iv_common/destination_file_writer.dart';
import 'package:svg2iv_common/extensions.dart';
import 'package:svg2iv_common/model/image_vector.dart';
import 'package:tuple/tuple.dart';

const destinationOptionName = 'destination';
const helpFlagName = 'help';
const receiverOptionName = 'receiver';
const socketAddressOptionName = 'socket-address';

void main(List<String> args) async {
  List<File> listSvgFilesRecursivelySync(Directory directory) => directory
      .listSync(recursive: true)
      .where((fse) =>
          fse is File &&
          (fse.path.endsWith('.svg') || fse.path.endsWith('.xml')))
      .cast<File>()
      .toList(growable: false);

  final argParser = ArgParser()
    ..addOption(
      destinationOptionName,
      abbr: 'd',
      help:
          """Either the path to the directory where you want the file(s) to be generated,
or the path to the file in which all the ImageVectors will be generated if you wish to have them all declared in a single file.
Will be created if it doesn't already exist and/or overwritten otherwise.
When specifying a path which leads to a non-existent entity, this tool will assume it should lead to a directory unless it ends with '.kt'
​""",
      valueHelp: 'destination_file.kt> or <directory',
    )
    ..addOption(
      receiverOptionName,
      abbr: 'r',
      help:
          """The name of the receiver type for which the extension property(ies) will be generated.
The type will NOT be created if it hasn't already been declared.
For example, passing '--receiver MyIcons fancy_icon.svg' will result in `MyIcons.FancyIcon` being generated.
If not provided, the generated property will be declared as a top-level property.
​""",
      valueHelp: 'receiver_type',
    )
    ..addOption(socketAddressOptionName, abbr: 's', defaultsTo: '', hide: true)
    ..addFlag(
      helpFlagName,
      abbr: 'h',
      help: 'Displays this usage information.',
      negatable: false,
    );
  ArgResults argResults;
  try {
    argResults = argParser.parse(args);
  } on ArgParserException catch (e) {
    stderr.writeln(e.message);
    exit(2);
  }
  final isHelpFlagSet = argResults[helpFlagName] as bool;
  if (isHelpFlagSet) {
    stdout
      ..writeln(
        'Usage: svg2iv [options] <comma-separated source files/directories>',
      )
      ..writeln()
      ..writeln('Options:')
      ..writeln(argParser.usage);
    return;
  }
  var sourceFiles = argResults.rest
      .expand(
        (rest) => rest.split(RegExp(',+')).where((s) => s.isNotEmpty).expand(
          (path) {
            if (FileSystemEntity.isFileSync(path)) {
              return [File(path)];
            } else {
              final directory = Directory(path);
              return directory.existsSync()
                  ? listSvgFilesRecursivelySync(directory)
                  : Iterable<File>.empty();
            }
          },
        ),
      )
      .toList(growable: false);
  if (sourceFiles.isEmpty) {
    stdout.writeln(
      'No source file(s) specified;'
      ' defaulting to files in the current working directory.',
    );
    sourceFiles = listSvgFilesRecursivelySync(Directory.current);
    if (sourceFiles.isEmpty) {
      stderr.writeln(
        'No SVG/XML files were found in the current working directory. Exiting.',
      );
      exit(2);
    }
  }
  FileSystemEntity? destination;
  final socketAddress = (argResults[socketAddressOptionName] as String)
      .split(':')
      .takeIf((splits) =>
          splits.length == 2 && splits.every((s) => !s.isNullOrEmpty));
  if (socketAddress == null) {
    // transmit instead of generating
    final destinationPath = argResults[destinationOptionName] as String?;
    if (destinationPath.isNullOrEmpty) {
      stdout.writeln('No valid destination directory specified;'
          ' defaulting to the current working directory.');
      destination = Directory.current;
    } else {
      Directory destinationDirectory;
      if (destinationPath!.endsWith('.kt')) {
        destination = File(destinationPath);
        destinationDirectory = destination.parent;
        stdout.writeln('Destination is assumed to be a file.');
      } else {
        destinationDirectory = destination = Directory(destinationPath);
      }
      if (!destinationDirectory.existsSync()) {
        stdout.writeln('Destination directory does not exist. Creating it…');
        try {
          destinationDirectory.createSync(recursive: true);
        } on FileSystemException {
          stderr.writeln(
            'Destination directory could not be created. Exiting.',
          );
          exit(2);
        }
      }
    }
  }
  final parseResult = parseFiles(sourceFiles);
  final imageVectors = <Tuple2<String, ImageVector>>[];
  for (int index = 0; index < parseResult.item1.length; index++) {
    final imageVector = parseResult.item1[index];
    if (imageVector != null) {
      final filePath = sourceFiles[index].path;
      final fileName = filePath.substring(
        filePath.lastIndexOf(Platform.pathSeparator) + 1,
        filePath.lastIndexOfOrNull('.'),
      );
      imageVectors.add(Tuple2(fileName, imageVector));
    }
  }
  final errorMessages = parseResult.item2;
  if (errorMessages.isNotEmpty) {
    exitCode = 1;
    errorMessages.forEach(stderr.writeln);
  }
  if (destination != null && imageVectors.isNotEmpty) {
    final extensionReceiver = argResults[receiverOptionName] as String?;
    if (destination is File) {
      await writeImageVectorsToFile(
        destination.path,
        imageVectors,
        extensionReceiver: extensionReceiver,
      );
    } else {
      for (final pair in imageVectors) {
        await writeImageVectorsToFile(
          destination.path + Platform.pathSeparator + pair.item1,
          [pair],
          extensionReceiver: extensionReceiver,
        );
      }
    }
  }
  if (socketAddress != null && socketAddress.every((it) => it.isNotEmpty)) {
    final host = InternetAddress.tryParse(socketAddress[0]);
    final portNumber = int.tryParse(socketAddress[1]);
    if (host == null || portNumber == null) {
      stderr.writeln('Socket address or port number could not be parsed.');
      exit(1);
    }
    await transmitProtobufImageVector(
      parseResult.item1,
      host,
      portNumber,
    ).catchError((_, stackTrace) => stderr.writeln(stackTrace));
  }
}
