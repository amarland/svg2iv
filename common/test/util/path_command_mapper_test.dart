import 'package:svg2iv_common/parser.dart';
import 'package:svg2iv_common/src/util/path_command_mapper.dart';
import 'package:test/test.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart' as vgc;

void main() {
  group('mapPathCommands() returns the expected pathNodes', () {
    group('moveTo + lineTo', () {
      test('absolute', () {
        final pathData = 'M5,5 H95 V95 H5 L5,5';
        final expectedPathNodes = const [
          MoveToNode(5.0, 5.0),
          LineToNode(95.0, 5.0),
          LineToNode(95.0, 95.0),
          LineToNode(5.0, 95.0),
          LineToNode(5.0, 5.0),
        ];
        final actualPathNodes = mapPathCommands(
          vgc.parseSvgPathData(pathData),
        );
        expect(actualPathNodes, orderedEquals(expectedPathNodes));
      });
    });
    test('with close', () {
      final pathData = 'M150,0 L75,200 L225,200 Z';
      final expectedPathNodes = const [
        MoveToNode(150.0, 0.0),
        LineToNode(75.0, 200.0),
        LineToNode(225.0, 200.0),
        CloseNode(),
      ];
      final actualPathNodes = mapPathCommands(
        vgc.parseSvgPathData(pathData),
      );
      expect(actualPathNodes, orderedEquals(expectedPathNodes));
    });
    group('curveTo', () {
      test('absolute', () {
        final pathData = 'M10,80 C40,10,65,10,95,80';
        final expectedPathNodes = const [
          MoveToNode(10.0, 80.0),
          CurveToNode(40.0, 10.0, 65.0, 10.0, 95.0, 80.0),
        ];
        final actualPathNodes = mapPathCommands(
          vgc.parseSvgPathData(pathData),
        );
        expect(actualPathNodes, orderedEquals(expectedPathNodes));
      });
    });
  });
}
