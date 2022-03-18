import 'dart:io';

import 'package:args/args.dart';
import 'package:svg2iv/image_vector_transmitter.dart';
import 'package:svg2iv_common/destination_file_writer.dart';
import 'package:svg2iv_common/extensions.dart';
import 'package:svg2iv_common/file_parser.dart';
import 'package:svg2iv_common/model/image_vector.dart';
import 'package:tuple/tuple.dart';

const destinationOptionName = 'destination';
const forceLottieFlagName = 'force-lottie';
const helpFlagName = 'help';
const quietFlagName = 'quiet';
const receiverOptionName = 'receiver';
const socketAddressOptionName = 'socket-address';

var _isInQuietMode = false;

void main(List<String> args) async {
  final argParser = ArgParser()
    ..addOption(
      destinationOptionName,
      abbr: 'd',
      help: """
Either the path to the directory where you want the file(s) to be generated,
or the path to the file in which all the ImageVectors will be generated
if you wish to have them all declared in a single file.
Will be created if it doesn't already exist and/or overwritten otherwise.
When specifying a path which leads to a non-existent entity, this tool
will assume it should lead to a directory unless it ends with '.kt'
​""",
      valueHelp: 'file.kt> or <dir',
    )
    ..addOption(
      receiverOptionName,
      abbr: 'r',
      help: """
The name of the receiver type for which the extension property(ies) will be
generated. The type will NOT be created if it hasn't already been declared.
For example, passing '--receiver MyIcons fancy_icon.svg' will result
in `MyIcons.FancyIcon` being generated.
If not set, the generated property will be declared as a top-level property.
​""",
      valueHelp: 'type',
    )
    ..addOption(socketAddressOptionName, abbr: 's', defaultsTo: '', hide: true)
    ..addFlag(
      quietFlagName,
      abbr: 'q',
      help: 'Show error messages only.',
      negatable: false,
    )
    ..addFlag(forceLottieFlagName, negatable: false, hide: true)
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
    _logError(e.message);
    exit(2);
  }
  _isInQuietMode = argResults[quietFlagName] as bool;
  if (argResults[helpFlagName] as bool) {
    stdout
      ..writeln(
        'Usage: svg2iv [options] <comma-separated source files/directories>',
      )
      ..writeln()
      ..writeln('Options:')
      ..writeln(argParser.usage);
    return;
  }
  List<Tuple2<File, SourceFileDefinitionType>> sourceFiles = argResults.rest
      .expand(
        (rest) => rest.split(RegExp(',+')).where((s) => s.isNotEmpty).expand(
          (path) sync* {
            if (FileSystemEntity.isDirectorySync(path)) {
              yield* _listSvgFilesRecursivelySync(Directory(path)).map(
                (file) => Tuple2(file, SourceFileDefinitionType.implicit),
              );
            } else if (FileSystemEntity.isFileSync(path)) {
              yield Tuple2(File(path), SourceFileDefinitionType.explicit);
            } else {
              _logError("'$path' does not exist!");
              if (argResults.rest.length == 1) {
                exit(2);
              }
            }
          },
        ),
      )
      .toNonGrowableList();
  if (sourceFiles.isEmpty) {
    _log(
      'No source file(s) specified;'
      ' defaulting to files in the current working directory.',
    );
    sourceFiles = _listSvgFilesRecursivelySync(Directory.current)
        .map((file) => Tuple2(file, SourceFileDefinitionType.implicit))
        .toNonGrowableList();
    if (sourceFiles.isEmpty) {
      _logError(
        'No SVG/XML files were found in the current working directory.'
        ' Exiting.',
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
    final destinationPath = argResults[destinationOptionName] as String?;
    if (destinationPath.isNullOrEmpty) {
      final String location;
      final directoryPaths = sourceFiles.map((pair) {
        final file = pair.item1;
        final pathSegments = file.uri.pathSegments;
        return pathSegments.isNotEmpty
            ? pathSegments
                .sublist(0, pathSegments.length - 1)
                .join(Platform.pathSeparator)
            : '';
      });
      final firstDirectoryPath = directoryPaths.first;
      if (directoryPaths.length == 1 ||
          directoryPaths.every((path) => path == firstDirectoryPath)) {
        location = 'source directory';
        destination = Directory(firstDirectoryPath);
      } else {
        location = 'current working directory';
        destination = Directory.current;
      }
      _log(
        'No valid destination directory specified; defaulting to $location.',
      );
    } else {
      Directory destinationDirectory;
      if (destinationPath!.endsWith('.kt')) {
        destination = File(destinationPath);
        destinationDirectory = destination.parent;
        _log('Destination is assumed to be a file.');
      } else {
        destinationDirectory = destination = Directory(destinationPath);
      }
      if (!destinationDirectory.existsSync()) {
        _log('Destination directory does not exist. Creating it…');
        try {
          destinationDirectory.createSync(recursive: true);
        } on FileSystemException {
          _logError(
            'Destination directory could not be created. Exiting.',
          );
          exit(2);
        }
      }
    }
  }
  final convertToLottie = argResults[forceLottieFlagName] as bool;
  final parseResult = parseFiles(
    sourceFiles,
    normalizePaths: convertToLottie,
  );
  final imageVectors = <Tuple2<String, ImageVector>>[];
  for (var index = 0; index < parseResult.item1.length; index++) {
    final imageVector = parseResult.item1[index];
    if (imageVector != null) {
      final filePath = sourceFiles[index].item1.path;
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
    errorMessages.forEach(_logError);
  }
  // `destination` is null if generation is skipped in favor of transmission
  if (destination != null) {
    if (imageVectors.isNotEmpty) {
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
      _log("File(s) generated in '${destination.path}'.");
    } else if (errorMessages.isEmpty) {
      // assume no eligible files were found
      _log('No eligible files were found.');
    }
  }
  if (socketAddress != null && socketAddress.every((it) => it.isNotEmpty)) {
    final host = InternetAddress.tryParse(socketAddress[0]);
    final portNumber = int.tryParse(socketAddress[1]);
    if (host == null || portNumber == null) {
      _logError('Socket address or port number could not be parsed.');
      exit(1);
    }
    await transmitProtobufImageVector(
      parseResult.item1,
      host,
      portNumber,
    ).catchError((_, stackTrace) => _logError(stackTrace));
  }
}

void _log(String message) {
  if (!_isInQuietMode) {
    stdout.writeln(message);
  }
}

void _logError(String message) {
  if (stderr.supportsAnsiEscapes) {
    message = '\u001B[31m$message\u001B[39m';
  }
  stderr.writeln(message);
}

Iterable<File> _listSvgFilesRecursivelySync(Directory directory) sync* {
  for (final entity in directory.listSync(recursive: true)) {
    if (entity is File) {
      final path = entity.path;
      final extension = path.substring(path.lastIndexOfOrNull('.') ?? 0);
      if (extension == '.svg' || extension == '.xml') {
        yield entity;
      }
    }
  }
}
