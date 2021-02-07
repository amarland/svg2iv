import 'package:svg2va/destination_file_writer.dart';
import 'package:svg2va/extensions.dart';
import 'package:svg2va/model/gradient.dart';
import 'package:svg2va/model/transformations.dart';
import 'package:svg2va/model/vector_group.dart';
import 'package:svg2va/model/vector_node.dart';
import 'package:svg2va/model/vector_path.dart';
import 'package:test/test.dart';

void main() {
  group('writePath() writes a DSL-compliant path declaration', () {
    const pathData = [
      PathNode(PathDataCommand.moveTo, [9.72, 10.93]),
      PathNode(PathDataCommand.verticalLineTo, [2.59]),
      PathNode(
        PathDataCommand.arcTo,
        [1.65, 1.65, 0.0, false, false, 8.0, 1.0],
      ),
      PathNode(
        PathDataCommand.arcTo,
        [1.65, 1.65, 0.0, false, false, 6.28, 2.59],
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
    const pathDataAsString = '''
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

    test('without attributes', () {
      final path = VectorPathBuilder(pathData).build();
      final expected = (StringBuffer()
            ..writeln('path {')
            ..writeln(pathDataAsString)
            ..writeln('}'))
          .toString();
      final actual = StringBuffer()
          .also((buffer) => writePath(buffer, path, 0))
          .toString();
      expect(actual, expected);
    });

    test('with only a solid fill color', () {
      const fillColor = 0x11223344;
      final path =
          VectorPathBuilder(pathData).fill(LinearGradient([fillColor])).build();
      final expected = (StringBuffer('''
path(
    fill = SolidColor(Color($fillColor)),
) {
''')..writeln(pathDataAsString)..writeln('}')).toString();
      final actual = StringBuffer()
          .also((buffer) => writePath(buffer, path, 0))
          .toString();
      expect(actual, expected);
    });

    test('with all attributes set and gradients', () {
      final path = VectorPathBuilder(pathData)
          .id('test_vector')
          .fill(LinearGradient(
            const [0x11223344, 0x55667788],
            startX: 1.0,
            startY: 2.0,
            endX: 3.0,
            endY: 4.0,
          ))
          .fillAlpha(0.5)
          .stroke(RadialGradient(
            const [0x11223344, 0x55667788, 0x99101112],
            stops: [0.25, 0.5, 0.75],
            centerX: 1.0,
            centerY: 2.0,
            radius: 3.0,
            tileMode: TileMode.clamp,
          ))
          .strokeAlpha(1.0)
          .strokeLineWidth(2.0)
          .strokeLineCap(StrokeCap.round)
          .strokeLineJoin(StrokeJoin.miter)
          .strokeLineMiter(3.0)
          .pathFillType(PathFillType.nonZero)
          .build();
      final expected = (StringBuffer('''
path(
    name = "TestVector",
    fill = Brush.linearGradient(
        listOf(Color(${0x11223344}), Color(${0x55667788})),
        startX = 1F,
        startY = 2F,
        endX = 3F,
        endY = 4F,
    ),
    fillAlpha = 0.5F,
    stroke = Brush.radialGradient(
        0.25F to Color(${0x11223344}),
        0.5F to Color(${0x55667788}),
        0.75F to Color(${0x99101112}),
        centerX = 1F,
        centerY = 2F,
        radius = 3F,
        tileMode = TileMode.Clamp,
    ),
    strokeAlpha = 1F,
    strokeLineWidth = 2F,
    strokeLineCap = StrokeCap.Round,
    strokeLineJoin = StrokeJoin.Miter,
    strokeLineMiter = 3F,
    pathFillType = PathFillType.NonZero,
) {
''')..writeln(pathDataAsString)..writeln('}')).toString();
      final actual = StringBuffer()
          .also((buffer) => writePath(buffer, path, 0))
          .toString();
      expect(actual, expected);
    });
  });
  group('writeGroup() writes a DSL-compliant group declaration', () {
    test('with both set and unset attributes', () {
      final group = VectorGroupBuilder()
          .id('test_group')
          .transformations(
            TransformationsBuilder()
                .rotation(const Rotation(30.0, pivotX: 5.0, pivotY: 5.0))
                .scale(Scale(1.2))
                .addTranslation(const Translation(9.0))
                .build()!,
          )
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
      final expected = '''
group(
    name = "TestGroup",
    rotation = 30F,
    pivotX = 5F,
    pivotY = 5F,
    scaleX = 1.2F,
    scaleY = 1.2F,
    translationX = 9F,
    translationY = 0F,
    clipPathData = listOf(
        PathNode.HorizontalTo(12F),
    ),
) {
    path {
        horizontalLineTo(24F)
    }
    group {
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
}
