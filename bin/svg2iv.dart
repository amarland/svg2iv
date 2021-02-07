// @dart=2.9

import 'dart:io';

import 'package:args/args.dart';
import 'package:svg2va/destination_file_writer.dart';
import 'package:svg2va/extensions.dart';
import 'package:svg2va/model/image_vector.dart';
import 'package:svg2va/protobuf/image_vector_adapter.dart';
import 'package:svg2va/protobuf/image_vector_transmitter.dart';
import 'package:svg2va/svg2iv.dart';
import 'package:svg2va/svg_parser_exception.dart';

const destinationOptionName = 'destination';
const helpFlagName = 'help';
const receiverOptionName = 'receiver';
const socketAddressOptionName = 'socket-address';

void main(List<String> args) async {
  Iterable<File> listSvgFilesRecursivelySync(Directory directory) => directory
      .listSync(recursive: true)
      .where((fse) => fse is File && fse.path.endsWith('.svg'))
      .cast<File>()
      .toSet();

  final argParser = ArgParser()
    ..addOption(
      destinationOptionName,
      abbr: 'd',
      help: (StringBuffer('Either the path to the directory where you want the'
              ' file(s) to be generated, or the path to the file in which all'
              ' the ImageVectors will be generated if you wish to have them all'
              ' declared in a single file.')
            ..writeln("Will be created if it doesn't already exist"
                ' and/or overwritten otherwise.')
            ..writeln('When specifying a path which leads to a non-existent'
                ' entity, this tool will assume it should lead to a directory'
                " unless it ends with '.kt'"))
          .toString(),
      valueHelp: 'destination_file[.kt]_or_directory',
    )
    ..addOption(
      receiverOptionName,
      abbr: 'r',
      help: (StringBuffer('The name of the receiver type for which'
              ' the extension property(ies) will be generated.')
            ..writeln("The type will NOT be created if it hasn't"
                ' already been declared.')
            ..writeln("For example, passing '--receiver MyIcons fancy_icon.svg'"
                ' will result in `MyIcons.FancyIcon` being generated.')
            ..writeln('If not provided, the generated property will be declared'
                ' as a top-level property.'))
          .toString(),
      valueHelp: 'receiver_type',
    )
    ..addOption(socketAddressOptionName, abbr: 's', hide: true)
    ..addFlag(
      helpFlagName,
      abbr: 'd',
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
  final isHelpFlagSet = argResults[helpFlagName] as bool ?? false;
  if (isHelpFlagSet) {
    stdout
      ..writeln('Usage: svg2iv <source_files/directories> [arguments]')
      ..writeln(argParser.usage);
    return;
  }
  var sourceFiles = argResults.rest.expand((rest) => rest
      .split(RegExp(r'\s+'))
      .where((s) => s.isNotEmpty)
      .expand((path) => FileSystemEntity.isFileSync(path)
          ? [File(path)]
          : Directory(path)
                  .takeIf((d) => d.existsSync())
                  ?.let((d) => listSvgFilesRecursivelySync(d)) ??
              Iterable.empty()));
  if (sourceFiles.isEmpty) {
    stdout.writeln(
      'No source file(s) specified;'
      ' defaulting to files in the current working directory.',
    );
    sourceFiles = listSvgFilesRecursivelySync(Directory.current);
    if (sourceFiles.isEmpty) {
      stderr.writeln(
        'No SVG files were found in the current working directory. Exiting.',
      );
      exit(2);
    }
  }
  FileSystemEntity destination;
  final socketAddress =
      (argResults[socketAddressOptionName] as String)?.split(':');
  if (socketAddress == null) {
    final destinationPath = argResults[destinationOptionName] as String;
    if (destinationPath.isNullOrEmpty) {
      stdout.writeln('No valid destination directory specified;'
          ' defaulting to the current working directory.');
      destination = Directory.current;
    }
    Directory destinationDirectory;
    if (destinationPath.endsWith('.kt')) {
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
        stderr.writeln('Destination directory could not be created. Exiting.');
        exit(2);
      }
    }
  }
  final imageVectors = Map.fromIterables(
    sourceFiles.map((f) => f.path),
    List<ImageVector>.filled(sourceFiles.length, null),
  );
  for (final source in sourceFiles) {
    if (!source.existsSync()) {
      stderr.writeln('${source.path} does not exist!');
      exitCode = 1;
    }
    try {
      final fileName = source.path.let(
        (p) => p.substring(
          p.lastIndexOf(Platform.pathSeparator) + 1,
          p.lastIndexOfOrNull('.'),
        ),
      );
      imageVectors[fileName] = parseSvgFile(source);
    } on SvgParserException catch (e) {
      stderr
        ..writeln('An error occurred while parsing ${source.path}:')
        ..writeln(e.message);
      exitCode = 1;
    } catch (e) {
      stderr.writeln(
        'An expected error occurred while parsing ${source.path}.',
      );
      exitCode = 1;
    }
  }
  if (destination != null && imageVectors.values.anyNotNull()) {
    final extensionReceiver = argResults[receiverOptionName] as String;
    if (destination is File) {
      writeImageVectorsToFile(
          destination.path, imageVectors, extensionReceiver);
    } else {
      imageVectors.forEach(
        (name, imageVector) => writeImageVectorsToFile(
          destination.path + Platform.pathSeparator + name,
          {name: imageVector},
          extensionReceiver,
        ),
      );
    }
  }
  if (socketAddress != null &&
      socketAddress.length == 2 &&
      socketAddress.every((it) => it.isNotEmpty)) {
    final host = InternetAddress(socketAddress[0]);
    final portNumber = int.tryParse(socketAddress[1]);
    await transmitProtobufImageVector(
      imageVectorIterableAsProtobuf(imageVectors.values),
      host,
      portNumber,
    ).catchError((_, stackTrace) => stderr.writeln(stackTrace));
  }
}
