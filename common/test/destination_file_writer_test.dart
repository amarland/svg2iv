import 'dart:convert';

import 'package:svg2iv_common/extensions.dart';
import 'package:svg2iv_common/writer.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

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
      final path =
          VectorPathBuilder(_pathData).fill(SolidColor(0x11223344)).build();
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
          .rotate(30.0, pivotX: 5.0, pivotY: 5.0)
          .scale(x: 1.2)
          .translate(x: 9.0)
          .build()!;
      final group = VectorGroupBuilder()
          .id('test_group')
          .transformations(transformations)
          .clipPathData(const [LineToNode(12.0, 6.0)])
          .addNode(
            VectorPathBuilder(const [LineToNode(24.0, 12.0)]).build(),
          )
          .addNode(
            VectorGroupBuilder()
                .transformations(
                  TransformationsBuilder().translate(x: 2.5).build()!,
                )
                .addNode(
                  VectorPathBuilder(const [LineToNode(3.0, 6.0)]).build(),
                )
                .build(),
          )
          .build();
      final expected = '''
group(
    name = "test_group",
    rotate = ${numToKotlinFloatAsString(transformations.rotation!.angle)},
    pivotX = ${numToKotlinFloatAsString(transformations.rotation!.pivotX!)},
    pivotY = ${numToKotlinFloatAsString(transformations.rotation!.pivotY!)},
    scaleX = ${numToKotlinFloatAsString(transformations.scale!.x)},
    scaleY = ${numToKotlinFloatAsString(transformations.scale!.y!)},
    translationX = ${numToKotlinFloatAsString(transformations.translation!.x)},
    clipPathData = listOf(
        PathNode.LineTo(12F, 6F),
    ),
) {
    path {
        lineTo(24F, 12F)
    }
    group(
        translationX = 2.5F,
    ) {
        path {
            lineTo(3F, 6F)
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

    for (final (description, vectorPath, intersection) in [
      (
        'with no gradient',
        VectorPathBuilder(_pathData).build(),
        <String>{},
      ),
      //
      (
        'with a gradient but without requiring `Offset`',
        VectorPathBuilder(_pathData)
            .fill(LinearGradient(const [0x11223344, 0x55667788]))
            .build(),
        {'import androidx.compose.ui.graphics.*'},
      ),
      //
      (
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
      actualTest(
        description,
        ImageVectorBuilder(24.0, 24.0)
            .addNode(
              VectorGroupBuilder()
                  .transformations(
                    TransformationsBuilder().scale(x: 0.5, y: 0.5).build()!,
                  )
                  .addNode(vectorPath)
                  .build(),
            )
            .addNode(VectorPathBuilder(_pathData).build())
            .build(),
        intersection,
      );
    }
  });

  test(
    'writeFileContents() generates code that can be compiled;'
    ' the embedded Kotlin compiler reports no errors',
    () {
      final imageVector = ImageVectorBuilder(24.0, 24.0)
          .name('test_vector')
          .tintColor(0x11223344)
          .tintBlendMode(BlendMode.modulate)
          .addNode(
            VectorGroupBuilder()
                .id('test_group')
                .transformations(TransformationsBuilder().rotate(90.0).build()!)
                .addNode(_buildVectorPath(trimPath: false))
                .build(),
          )
          .addNode(_buildVectorPath(trimPath: true))
          .build();
      final dependencyAnnotations = '''
@file:Repository("https://maven.pkg.jetbrains.space/public/p/compose/dev/")
@file:DependsOn("org.jetbrains.compose.ui:ui-desktop:1.4.0")
@file:DependsOn("org.jetbrains.compose.ui:ui-geometry-desktop:1.4.0")
@file:DependsOn("org.jetbrains.compose.ui:ui-graphics-desktop:1.4.0")
@file:DependsOn("org.jetbrains.compose.ui:ui-unit-desktop:1.4.0")

''';
      final generatedSourceBuffer = StringBuffer(dependencyAnnotations);
      writeFileContents(generatedSourceBuffer, [imageVector]);
      generatedSourceBuffer.writeln('\nprint(TestVector.name)');
      final (resultString, errorString) = executeKotlinScript(
        generatedSourceBuffer.toString(),
      );
      expect(errorString.isEmpty, true, reason: errorString);
      expect(resultString, 'TestVector');
    },
    tags: ['include-windows'],
  );
}

const _pathData = [
  MoveToNode(9.72, 10.93),
  LineToNode(9.72, 2.59),
  ArcToNode(
    rx: 1.65,
    ry: 1.65,
    angle: 0.0,
    largeArc: false,
    sweep: false,
    x: 8.0,
    y: 1.0,
  ),
  ArcToNode(
    rx: 1.650,
    ry: 1.6500,
    angle: 0.0,
    largeArc: false,
    sweep: false,
    x: 6.28,
    y: 2.59,
  ),
  LineToNode(6.28, 11.0),
  ArcToNode(
    rx: 2.11,
    ry: 2.11,
    angle: 0.0,
    largeArc: false,
    sweep: false,
    x: -0.83,
    y: 1.65,
  ),
  ArcToNode(
    rx: 2.48,
    ry: 2.48,
    angle: 0.0,
    largeArc: false,
    sweep: false,
    x: 8.0,
    y: 15.0,
  ),
  ArcToNode(
    rx: 2.44,
    ry: 2.44,
    angle: 0.0,
    largeArc: false,
    sweep: false,
    x: 2.55,
    y: -2.35,
  ),
  ArcToNode(
    rx: 2.34,
    ry: 2.34,
    angle: 0.0,
    largeArc: false,
    sweep: false,
    x: 9.72,
    y: 10.93,
  ),
  CloseNode(),
];

const _pathDataAsString = '''
    moveTo(9.72F, 10.93F)
    lineTo(9.72F, 2.59F)
    arcTo(1.65F, 1.65F, 0F, false, false, 8F, 1F)
    arcTo(1.65F, 1.65F, 0F, false, false, 6.28F, 2.59F)
    lineTo(6.28F, 11F)
    arcTo(2.11F, 2.11F, 0F, false, false, -0.83F, 1.65F)
    arcTo(2.48F, 2.48F, 0F, false, false, 8F, 15F)
    arcTo(2.44F, 2.44F, 0F, false, false, 2.55F, -2.35F)
    arcTo(2.34F, 2.34F, 0F, false, false, 9.72F, 10.93F)
    close()''';

String _pathDataAsNonDslString({required int indentationLevel}) => '''
listOf(
    PathNode.MoveTo(9.72F, 10.93F),
    PathNode.LineTo(9.72F, 2.59F),
    PathNode.ArcTo(1.65F, 1.65F, 0F, false, false, 8F, 1F),
    PathNode.ArcTo(1.65F, 1.65F, 0F, false, false, 6.28F, 2.59F),
    PathNode.LineTo(6.28F, 11F),
    PathNode.ArcTo(2.11F, 2.11F, 0F, false, false, -0.83F, 1.65F),
    PathNode.ArcTo(2.48F, 2.48F, 0F, false, false, 8F, 15F),
    PathNode.ArcTo(2.44F, 2.44F, 0F, false, false, 2.55F, -2.35F),
    PathNode.ArcTo(2.34F, 2.34F, 0F, false, false, 9.72F, 10.93F),
    PathNode.Close,
)'''
    .replaceAll('\n', '\n${List.filled(indentationLevel * 4, ' ').join()}');

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
