import 'package:svg2iv_common/parser.dart';
import 'package:svg2iv_common/src/util/path_command_mapper.dart';
import 'package:test/test.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart' as vgc;

void main() {
  group('mapPathCommands() returns the expected pathNodes', () {
    group('moveTo + [h|v]lineTo', () {
      test('absolute', () {
        final pathData = 'M5,5 H95 V95 H5 L5,5';
        final expectedPathNodes = const [
          PathNode(PathDataCommand.moveTo, [5.0, 5.0]),
          PathNode(PathDataCommand.lineTo, [95.0, 0.0]),
          PathNode(PathDataCommand.lineTo, [0.0, 95.0]),
          PathNode(PathDataCommand.lineTo, [5.0, 0.0]),
          PathNode(PathDataCommand.lineTo, [5.0, 5.0]),
        ];
        final actualPathNodes = mapPathCommands(
          vgc.parseSvgPathData(pathData),
        );
        expect(actualPathNodes, orderedEquals(expectedPathNodes));
      });
    });
    test('with close', () {
      final pathData = 'M150 0 L75 200 L225 200 Z';
      final expectedPathNodes = const [
        PathNode(PathDataCommand.moveTo, [150.0, 0.0]),
        PathNode(PathDataCommand.lineTo, [75.0, 200.0]),
        PathNode(PathDataCommand.lineTo, [225.0, 200.0]),
        PathNode(PathDataCommand.close, []),
      ];
      final actualPathNodes = mapPathCommands(
        vgc.parseSvgPathData(pathData),
      );
      expect(actualPathNodes, orderedEquals(expectedPathNodes));
    });
    group('curveTo', () {
      test('absolute', () {
        final pathData = 'M10,80 C40,10,65,10,95,80 S150,150,180,80';
        final expectedPathNodes = const [
          PathNode(PathDataCommand.moveTo, [10.0, 80.0]),
          PathNode(
            PathDataCommand.curveTo,
            [40.0, 10.0, 65.0, 10.0, 95.0, 80.0],
          ),
        ];
        final actualPathNodes = mapPathCommands(
          vgc.parseSvgPathData(pathData),
        );
        expect(actualPathNodes, orderedEquals(expectedPathNodes));
      });
    });
    group('with arcTo', () {
      test('absolute', () {
        final pathData = 'M10,315 L110,215 A30,50,0,0,1,162.55,162.45'
            'L172.55,152.45 A30,50,-45,0,1,215.1,109.9 L315,10';
        final expectedPathNodes = const [
          PathNode(PathDataCommand.moveTo, [10.0, 315.0]),
          PathNode(PathDataCommand.lineTo, [110.0, 215.0]),
          PathNode(
            PathDataCommand.arcTo,
            [30.0, 50.0, 0.0, false, true, 162.55, 162.45],
          ),
          PathNode(PathDataCommand.lineTo, [172.55, 152.45]),
          PathNode(
            PathDataCommand.arcTo,
            [30.0, 50.0, -45.0, false, true, 215.1, 109.9],
          ),
          PathNode(PathDataCommand.lineTo, [315, 10]),
        ];
        final actualPathNodes = mapPathCommands(
          vgc.parseSvgPathData(pathData),
        );
        expect(actualPathNodes, orderedEquals(expectedPathNodes));
      });
    });
  });
}
