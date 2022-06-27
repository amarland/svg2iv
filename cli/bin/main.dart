import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:svg2iv/image_vector_json_adapter.dart';
import 'package:svg2iv_common/parser.dart';
import 'package:svg2iv_common/utils.dart';
import 'package:svg2iv_common/writer.dart';

const outputOptionName = 'output';
const forceLottieFlagName = 'force-lottie';
const helpFlagName = 'help';
const quietFlagName = 'quiet';
const receiverOptionName = 'receiver';
const jsonFlagName = 'json'; // overrides '--output'

var _isInQuietMode = false;

void main(List<String> args) async {
  final argParser = ArgParser()
    ..addOption(
      outputOptionName,
      abbr: 'o',
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
For example, passing '--receiver=MyIcons fancy_icon.svg' will result
in `MyIcons.FancyIcon` being generated.
If not set, the generated property will be declared as a top-level property.
​""",
      valueHelp: 'type',
    )
    ..addFlag(jsonFlagName, negatable: false, hide: true)
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
  final outputOptionValue = argResults[outputOptionName] as String?;
  final convertToLottie = argResults[forceLottieFlagName] as bool;
  final isOutputJson = argResults[jsonFlagName] as bool && !convertToLottie;
  final shouldWriteToStdOut = outputOptionValue == '-' || isOutputJson;
  _isInQuietMode = shouldWriteToStdOut || argResults[quietFlagName] as bool;
  if (argResults[helpFlagName] as bool) {
    stdout
      ..writeln(
        'Usage: svg2iv.exe [options]'
        ' <comma-separated source files/directories>',
      )
      ..writeln()
      ..writeln('Options:')
      ..writeln(argParser.usage);
    return;
  }
  List<Tuple2<File, SourceDefinitionType>> sourceFiles = argResults.rest
      .expand(
        (rest) => rest.split(RegExp(',+')).where((s) => s.isNotEmpty).expand(
          (path) sync* {
            if (FileSystemEntity.isDirectorySync(path)) {
              yield* _listSvgFilesRecursivelySync(Directory(path)).map(
                (file) => Tuple2(file, SourceDefinitionType.implicit),
              );
            } else if (FileSystemEntity.isFileSync(path)) {
              yield Tuple2(File(path), SourceDefinitionType.explicit);
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
  String? sourceString;
  if (sourceFiles.isEmpty) {
    final inBytes = BytesBuilder();
    await for (final bytes in stdin) {
      inBytes.add(bytes);
    }
    if (inBytes.isNotEmpty) {
      sourceString = utf8.decode(inBytes.toBytes());
    } else {
      _log(
        'No source file(s) specified;'
        ' defaulting to files in the current working directory.',
      );
      sourceFiles = _listSvgFilesRecursivelySync(Directory.current)
          .map((file) => Tuple2(file, SourceDefinitionType.implicit))
          .toNonGrowableList();
      if (sourceFiles.isEmpty) {
        _logError(
          'No SVG/XML files were found in the current working directory.'
          ' Exiting.',
        );
        exit(2);
      }
    }
  }
  FileSystemEntity? destination;
  if (!shouldWriteToStdOut) {
    if (outputOptionValue.isNullOrEmpty) {
      final String location;
      final directoryPaths = sourceFiles.map((pair) {
        final file = pair.item1;
        final pathSegments = file.uri.pathSegments;
        return pathSegments.isNotEmpty
            ? pathSegments
                .slice(0, pathSegments.length - 1)
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
      if (outputOptionValue!.endsWith('.kt')) {
        destination = File(outputOptionValue);
        destinationDirectory = destination.parent;
        _log('Destination is assumed to be a file.');
      } else {
        destinationDirectory = destination = Directory(outputOptionValue);
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
  final imageVectors = List<ImageVector?>.empty(growable: true);
  final errorMessages = List<String>.empty(growable: true);
  if (sourceString != null) {
    final parseResult = parseXmlString(sourceString);
    final imageVector = parseResult.item1;
    imageVectors.add(
      imageVector?.name != null
          ? imageVector
          : imageVector?.copyWith(
              name: destination is File
                  ? destination.getNameWithoutExtension()
                  : null,
            ),
    );
    errorMessages.addAll(parseResult.item2);
  } else {
    for (final file in sourceFiles) {
      final parseResult = parseXmlFile(
        file,
        normalizePaths: convertToLottie,
      );
      final imageVector = parseResult.item1;
      imageVectors.add(
        imageVector?.name != null
            ? imageVector
            : imageVector?.copyWith(name: file.item1.getNameWithoutExtension()),
      );
      errorMessages.addAll(parseResult.item2);
    }
  }
  if (errorMessages.isNotEmpty) {
    exitCode = 1;
    errorMessages.forEach(_logError);
  }
  // `destination` is null if the actual destination
  // is the standard output stream
  if (isOutputJson) {
    stdout.write(imageVectors.toJson());
  } else {
    final nonNullImageVectors = imageVectors.whereNotNull().toNonGrowableList();
    if (nonNullImageVectors.isNotEmpty) {
      final extensionReceiver = argResults[receiverOptionName] as String?;
      if (destination != null) {
        if (destination is File) {
          await writeImageVectorsToFile(
            destination.path,
            nonNullImageVectors,
            extensionReceiver: extensionReceiver,
          );
        } else {
          for (final imageVector in nonNullImageVectors) {
            await writeImageVectorsToFile(
              destination.path +
                  Platform.pathSeparator +
                  (imageVector.name ?? 'your_name_here'),
              [imageVector],
              extensionReceiver: extensionReceiver,
            );
          }
        }
        _log("File(s) generated in '${destination.path}'.");
      } else {
        if (convertToLottie) {
          final lastIndex = nonNullImageVectors.length - 1;
          for (var index = 0; index <= lastIndex; index++) {
            final imageVector = nonNullImageVectors[index];
            stdout.write(imageVector.toLottieJson());
            if (index < lastIndex) {
              stdout
                ..writeln()
                ..writeln('--------------------');
            }
          }
        } else {
          writeFileContents(
            stdout,
            nonNullImageVectors,
            extensionReceiver: extensionReceiver,
          );
        }
      }
    } else if (errorMessages.isEmpty) {
      // assume no eligible files were found
      _log('No eligible files were found.');
    }
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
