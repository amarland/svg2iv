import 'dart:convert';
import 'dart:io';

import 'package:svg2iv_common/destination_file_writer.dart';
import 'package:svg2iv_common/extensions.dart';
import 'package:svg2iv_common/model/gradient.dart';
import 'package:svg2iv_common/model/image_vector.dart';
import 'package:svg2iv_common/model/transformations.dart';
import 'package:svg2iv_common/model/vector_group.dart';
import 'package:svg2iv_common/model/vector_node.dart';
import 'package:svg2iv_common/model/vector_path.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

void main() {
  group('writePath() writes a DSL-compliant path declaration', () {
    test('without attributes', () {
      final path = VectorPathBuilder(_pathData).build();
      final expected = (StringBuffer()
            ..writeln('path {')
            ..writeln(_pathDataAsString)
            ..writeln('}'))
          .toString();
      final actual = StringBuffer()
          .also((buffer) => writePath(buffer, path, 0))
          .toString();
      expect(actual, expected);
    });

    test('with only a solid fill color', () {
      final path = VectorPathBuilder(_pathData)
          .fill(LinearGradient([0x11223344]))
          .build();
      final expected = (StringBuffer('''
path(
    fill = SolidColor(Color(0x11223344)),
) {
''')
            ..writeln(_pathDataAsString)
            ..writeln('}'))
          .toString();
      final actual = StringBuffer()
          .also((buffer) => writePath(buffer, path, 0))
          .toString();
      expect(actual, expected);
    });

    test('with non-trimmed path, all attributes set and gradients', () {
      final actual = StringBuffer()
          .also((buffer) =>
              writePath(buffer, _buildVectorPath(trimPath: false), 0))
          .toString();
      expect(actual, _pathAsDslString);
    });

    test('with trimmed path, all attributes set and gradients', () {
      final actual = StringBuffer()
          .also((buffer) =>
              writePath(buffer, _buildVectorPath(trimPath: true), 0))
          .toString();
      expect(actual, _trimmedPathAsNonDslString);
    });
  });

  group('writeGroup() writes a DSL-compliant group declaration', () {
    test('with both set and unset attributes', () {
      final transformations = TransformationsBuilder()
          .rotate(angleInDegrees: 30.0, pivotX: 5.0, pivotY: 5.0)
          .scale(x: 1.2)
          .translate(x: 9.0)
          .build()!;
      final group = VectorGroupBuilder()
          .id('test_group')
          .transformations(transformations)
          .clipPathData(
            const [
              PathNode(PathDataCommand.horizontalLineTo, [12.0])
            ],
          )
          .addNode(
            VectorPathBuilder(
              const [
                PathNode(PathDataCommand.horizontalLineTo, [24.0])
              ],
            ).build(),
          )
          .addNode(
            VectorGroupBuilder()
                .transformations(
                  TransformationsBuilder().translate(x: 2.5).build()!,
                )
                .addNode(
                  VectorPathBuilder(
                    const [
                      PathNode(PathDataCommand.verticalLineTo, [6.0])
                    ],
                  ).build(),
                )
                .build(),
          )
          .build();
      // `pivotX` and `pivotY` are omitted because "absorbed" by
      // the translation; refer to `transformations.dart`
      final expected = '''
group(
    name = "test_group",
    rotate = ${numToKotlinFloatAsString(transformations.rotation!.angle)},
    scaleX = ${numToKotlinFloatAsString(transformations.scale!.x)},
    scaleY = ${numToKotlinFloatAsString(transformations.scale!.y!)},
    translationX = ${numToKotlinFloatAsString(transformations.translation!.x)},
    translationY = ${numToKotlinFloatAsString(transformations.translation!.y)},
    clipPathData = listOf(
        PathNode.HorizontalTo(12F),
    ),
) {
    path {
        horizontalLineTo(24F)
    }
    group(
        translationX = 2.5F,
    ) {
        path {
            verticalLineTo(6F)
        }
    }
}
''';
      final actual = StringBuffer()
          .also((buffer) => writeGroup(buffer, group, 0))
          .toString();
      expect(actual, expected);
    });
  });

  group('writeImports() generates code with no missing or extra imports', () {
    void actualTest(
      String description,
      ImageVector imageVector,
      Set<String> intersection,
    ) {
      test(description, () {
        final buffer = StringBuffer();
        writeImports(buffer, [imageVector]);
        final imports = LineSplitter().convert(buffer.toString()).toSet();
        expect(
          imports.intersection({
            'import androidx.compose.ui.geometry.Offset',
            'import androidx.compose.ui.graphics.*',
          }),
          unorderedEquals(intersection),
        );
      });
    }

    for (final pair in [
      Tuple3(
        'with no gradient',
        VectorPathBuilder(_pathData).build(),
        <String>{},
      ),
      //
      Tuple3(
        'with a gradient but without requiring `Offset`',
        VectorPathBuilder(_pathData)
            .fill(LinearGradient(const [0x11223344, 0x55667788]))
            .build(),
        {'import androidx.compose.ui.graphics.*'},
      ),
      //
      Tuple3(
        'with a gradient and requiring `Offset`',
        VectorPathBuilder(_pathData)
            .fill(LinearGradient(const [0x11223344, 0x55667788], endX: 20.0))
            .build(),
        {
          'import androidx.compose.ui.geometry.Offset',
          'import androidx.compose.ui.graphics.*',
        },
      ),
    ]) {
      final description = pair.item1;
      final vectorPath = pair.item2;
      final intersection = pair.item3;
      actualTest(
        description,
        ImageVectorBuilder(24.0, 24.0)
            .addNode(VectorGroupBuilder()
                .transformations(
                  TransformationsBuilder().scale(x: 0.5, y: 0.5).build()!,
                )
                .fillAlpha(0.3)
                .addNode(vectorPath)
                .build())
            .addNode(VectorPathBuilder(_pathData).build())
            .build(),
        intersection,
      );
    }
  });

  group('writeFileContents() generates code that can be compiled', () {
    test('the embedded Kotlin compiler reports no errors', () {
      final imageVector = ImageVectorBuilder(24.0, 24.0)
          .name('test_vector')
          .tintColor(0x11223344)
          .tintBlendMode(BlendMode.modulate)
          .addNode(
            VectorGroupBuilder()
                .id('test_group')
                .transformations(
                  TransformationsBuilder()
                      .rotate(angleInDegrees: 90.0)
                      .build()!,
                )
                .addNode(_buildVectorPath(trimPath: false))
                .build(),
          )
          .addNode(_buildVectorPath(trimPath: true))
          .build();
      final generatedSourceBuffer = StringBuffer();
      writeFileContents(
        generatedSourceBuffer,
        [Tuple2('test_vector.svg', imageVector)],
      );
      final dependencyAnnotations = '''
@file:Repository("https://maven.pkg.jetbrains.space/public/p/compose/dev/")
@file:DependsOn("org.jetbrains.compose.ui:ui-desktop:1.0.0-alpha3")
@file:DependsOn("org.jetbrains.compose.ui:ui-geometry-desktop:1.0.0-alpha3")
@file:DependsOn("org.jetbrains.compose.ui:ui-graphics-desktop:1.0.0-alpha3")
@file:DependsOn("org.jetbrains.compose.ui:ui-unit-desktop:1.0.0-alpha3")

''';
      final generatedSource = generatedSourceBuffer.toString();
      final tempDirectoryPath = Directory.systemTemp.path;
      final scriptSourceFile = File(tempDirectoryPath + '/test_script.main.kts')
        ..createSync()
        ..writeAsStringSync(dependencyAnnotations)
        ..writeAsStringSync(
          generatedSource,
          mode: FileMode.append,
        )
        ..writeAsStringSync(
          "\nprint(TestVector.name)",
          mode: FileMode.append,
          flush: true,
        );
      final workingDirectory = Directory('$tempDirectoryPath/kotlinc');
      final workingDirectoryPath = workingDirectory.path.replaceAll('\\', '/');
      if (!workingDirectory.existsSync() ||
          workingDirectory
              .listSync()
              .where((e) => e is Directory || e is File)
              .isEmpty) {
        final compilerArchiveFile =
            Directory('test_tool').listSync().singleWhere(
          (e) {
            // ignore: unnecessary_string_escapes
            final fileNameRegExp = RegExp('''kotlin-compiler-.{3,6}\.zip''');
            return fileNameRegExp.allMatches(e.path).length == 1;
          },
          orElse: () => fail(
            'The archive file containing the Kotlin compiler'
            ' could not be found!',
          ),
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
        final result = Process.runSync(
          Platform.isWindows ? 'powershell' : executable,
          [
            '-cp',
            '$workingDirectoryPath/lib/kotlin-main-kts.jar',
            '-script',
            scriptSourceFile.path,
          ].also((args) {
            // on Windows, the actual executable is 'powershell.exe',
            // so the first argument has to be 'kotlinc.bat'
            if (Platform.isWindows) args.insert(0, '$executable.bat');
          }),
        );
        final errorString = result.stderr as String;
        final resultString = result.stdout as String;
        expect(errorString.isEmpty, true, reason: errorString);
        expect(resultString, 'TestVector');
      } finally {
        scriptSourceFile.deleteSync();
      }
    });
  });
}

const _pathData = [
  PathNode(PathDataCommand.moveTo, [9.72, 10.93]),
  PathNode(PathDataCommand.verticalLineTo, [2.59]),
  PathNode(
    PathDataCommand.arcTo,
    [1.65, 1.65, 0.0, false, false, 8.0, 1.0],
  ),
  PathNode(
    PathDataCommand.arcTo,
    [1.650, 1.6500, 0.0, false, false, 6.28, 2.59],
  ),
  PathNode(PathDataCommand.verticalLineTo, [11.0]),
  PathNode(
    PathDataCommand.relativeArcTo,
    [2.11, 2.11, 0.0, false, false, -0.83, 1.65],
  ),
  PathNode(
    PathDataCommand.arcTo,
    [2.48, 2.48, 0.0, false, false, 8.0, 15.0],
  ),
  PathNode(
    PathDataCommand.relativeArcTo,
    [2.44, 2.44, 0.0, false, false, 2.55, -2.35],
  ),
  PathNode(
    PathDataCommand.arcTo,
    [2.34, 2.34, 0.0, false, false, 9.72, 10.93],
  ),
  PathNode(PathDataCommand.close, []),
];

const _pathDataAsString = '''
    moveTo(9.72F, 10.93F)
    verticalLineTo(2.59F)
    arcTo(1.65F, 1.65F, 0F, false, false, 8F, 1F)
    arcTo(1.65F, 1.65F, 0F, false, false, 6.28F, 2.59F)
    verticalLineTo(11F)
    arcToRelative(2.11F, 2.11F, 0F, false, false, -0.83F, 1.65F)
    arcTo(2.48F, 2.48F, 0F, false, false, 8F, 15F)
    arcToRelative(2.44F, 2.44F, 0F, false, false, 2.55F, -2.35F)
    arcTo(2.34F, 2.34F, 0F, false, false, 9.72F, 10.93F)
    close()''';

String _pathDataAsNonDslString({required int indentationLevel}) => '''
listOf(
    PathNode.MoveTo(9.72F, 10.93F),
    PathNode.VerticalTo(2.59F),
    PathNode.ArcTo(1.65F, 1.65F, 0F, false, false, 8F, 1F),
    PathNode.ArcTo(1.65F, 1.65F, 0F, false, false, 6.28F, 2.59F),
    PathNode.VerticalTo(11F),
    PathNode.RelativeArcTo(2.11F, 2.11F, 0F, false, false, -0.83F, 1.65F),
    PathNode.ArcTo(2.48F, 2.48F, 0F, false, false, 8F, 15F),
    PathNode.RelativeArcTo(2.44F, 2.44F, 0F, false, false, 2.55F, -2.35F),
    PathNode.ArcTo(2.34F, 2.34F, 0F, false, false, 9.72F, 10.93F),
    PathNode.Close,
)'''
    .replaceAll('\n', '\n' + List.filled(indentationLevel * 4, ' ').join());

VectorPath _buildVectorPath({required bool trimPath}) =>
    VectorPathBuilder(_pathData)
        .id(trimPath ? 'trimmed_path' : 'non_trimmed_path')
        .fill(
          LinearGradient(
            const [0x11223344, 0x55667788],
            startX: 1.0,
            startY: 2.0,
            endX: 3.0,
            endY: 4.0,
          ),
        )
        .fillAlpha(0.5)
        .stroke(
          RadialGradient(
            const [0x11223344, 0x55667788, 0x99101112],
            stops: [0.25, 0.5, 0.75],
            centerX: 1.0,
            centerY: 2.0,
            radius: 3.0,
            tileMode: TileMode.clamp,
          ),
        )
        .strokeAlpha(1.0)
        .strokeLineWidth(2.0)
        .strokeLineCap(StrokeCap.round)
        .strokeLineJoin(StrokeJoin.miter)
        .strokeLineMiter(3.0)
        .pathFillType(PathFillType.nonZero)
        .let((builder) => trimPath ? builder.trimPathStart(0.15) : builder)
        .build();

const _pathAsDslString = '''
path(
    name = "non_trimmed_path",
    fill = Brush.linearGradient(
        listOf(
            Color(0x11223344),
            Color(0x55667788),
        ),
        start = Offset(1F, 2F),
        end = Offset(3F, 4F),
    ),
    fillAlpha = 0.5F,
    stroke = Brush.radialGradient(
        0.25F to Color(0x11223344),
        0.5F to Color(0x55667788),
        0.75F to Color(0x99101112),
        center = Offset(1F, 2F),
        radius = 3F,
        tileMode = TileMode.Clamp,
    ),
    strokeLineWidth = 2F,
    strokeLineCap = StrokeCap.Round,
    strokeLineMiter = 3F,
) {
$_pathDataAsString
}
''';

final _trimmedPathAsNonDslString = '''
addPath(
    pathData = ${_pathDataAsNonDslString(indentationLevel: 1)},
    name = "trimmed_path",
    fill = Brush.linearGradient(
        listOf(
            Color(0x11223344),
            Color(0x55667788),
        ),
        start = Offset(1F, 2F),
        end = Offset(3F, 4F),
    ),
    fillAlpha = 0.5F,
    stroke = Brush.radialGradient(
        0.25F to Color(0x11223344),
        0.5F to Color(0x55667788),
        0.75F to Color(0x99101112),
        center = Offset(1F, 2F),
        radius = 3F,
        tileMode = TileMode.Clamp,
    ),
    strokeLineWidth = 2F,
    strokeLineCap = StrokeCap.Round,
    strokeLineMiter = 3F,
    trimPathStart = 0.15F,
)
''';
