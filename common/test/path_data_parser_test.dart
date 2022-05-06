import 'package:svg2iv_common/parser.dart';
import 'package:test/test.dart';

void main() {
  group('parsePathData() returns the expected pathNodes;', () {
    test('null', () {
      expect(parsePathData(null), List<PathNode>.empty());
    });
    group('moveTo + [h|v]lineTo;', () {
      test('relative', () {
        final pathData = 'm5,5 h90 v90 h-90 l0,-90';
        final expectedPathNodes = const [
          PathNode(PathDataCommand.relativeMoveTo, [5.0, 5.0]),
          PathNode(PathDataCommand.relativeHorizontalLineTo, [90.0]),
          PathNode(PathDataCommand.relativeVerticalLineTo, [90.0]),
          PathNode(PathDataCommand.relativeHorizontalLineTo, [-90.0]),
          PathNode(PathDataCommand.relativeLineTo, [0.0, -90.0]),
        ];
        final actualPathNodes = parsePathData(pathData);
        expect(actualPathNodes, orderedEquals(expectedPathNodes));
      });
      test('absolute', () {
        final pathData = 'M5,5 H95 V95 H5 L5,5';
        final expectedPathNodes = const [
          PathNode(PathDataCommand.moveTo, [5.0, 5.0]),
          PathNode(PathDataCommand.horizontalLineTo, [95.0]),
          PathNode(PathDataCommand.verticalLineTo, [95.0]),
          PathNode(PathDataCommand.horizontalLineTo, [5.0]),
          PathNode(PathDataCommand.lineTo, [5.0, 5.0]),
        ];
        final actualPathNodes = parsePathData(pathData);
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
      final actualPathNodes = parsePathData(pathData);
      expect(actualPathNodes, orderedEquals(expectedPathNodes));
    });
    group('curveTo + smoothCurveTo;', () {
      test('relative', () {
        final pathData = 'M10,80 c30,-70,55,-70,85,0 s55,70,85,0';
        final expectedPathNodes = const [
          PathNode(PathDataCommand.moveTo, [10.0, 80.0]),
          PathNode(
            PathDataCommand.relativeCurveTo,
            [30.0, -70.0, 55.0, -70.0, 85.0, 0.0],
          ),
          PathNode(
            PathDataCommand.relativeSmoothCurveTo,
            [55.0, 70.0, 85.0, 0.0],
          ),
        ];
        final actualPathNodes = parsePathData(pathData);
        expect(actualPathNodes, orderedEquals(expectedPathNodes));
      });
      test('absolute', () {
        final pathData = 'M10,80 C40,10,65,10,95,80 S150,150,180,80';
        final expectedPathNodes = const [
          PathNode(PathDataCommand.moveTo, [10.0, 80.0]),
          PathNode(
            PathDataCommand.curveTo,
            [40.0, 10.0, 65.0, 10.0, 95.0, 80.0],
          ),
          PathNode(
            PathDataCommand.smoothCurveTo,
            [150.0, 150.0, 180.0, 80.0],
          ),
        ];
        final actualPathNodes = parsePathData(pathData);
        expect(actualPathNodes, orderedEquals(expectedPathNodes));
      });
    });
    group('quadTo + smoothQuadTo;', () {
      test('relative', () {
        final pathData = 'M10,80 q42.5,-70,85,0 t85,0';
        final expectedPathNodes = const [
          PathNode(PathDataCommand.moveTo, [10.0, 80.0]),
          PathNode(
            PathDataCommand.relativeQuadraticBezierCurveTo,
            [42.5, -70.0, 85.0, 0.0],
          ),
          PathNode(
            PathDataCommand.relativeSmoothQuadraticBezierCurveTo,
            [85.0, 0.0],
          ),
        ];
        final actualPathNodes = parsePathData(pathData);
        expect(actualPathNodes, orderedEquals(expectedPathNodes));
      });
      test('absolute', () {
        final pathData = 'M10,80 Q52.5,10,95,80 T180,80';
        final expectedPathNodes = const [
          PathNode(PathDataCommand.moveTo, [10.0, 80.0]),
          PathNode(
            PathDataCommand.quadraticBezierCurveTo,
            [52.5, 10.0, 95.0, 80.0],
          ),
          PathNode(
            PathDataCommand.smoothQuadraticBezierCurveTo,
            [180.0, 80.0],
          ),
        ];
        final actualPathNodes = parsePathData(pathData);
        expect(actualPathNodes, orderedEquals(expectedPathNodes));
      });
    });
    group('with arcTo;', () {
      test('relative', () {
        final pathData = 'M10,315 l100,-100 a30,50,0,0,1,52.55,-52.55'
            'l10,-10 a30,50,-45,0,1,42.55,-42.55 l99.9,-99.9';
        final expectedPathNodes = const [
          PathNode(PathDataCommand.moveTo, [10.0, 315.0]),
          PathNode(PathDataCommand.relativeLineTo, [100.0, -100.0]),
          PathNode(
            PathDataCommand.relativeArcTo,
            [30.0, 50.0, 0.0, false, true, 52.55, -52.55],
          ),
          PathNode(PathDataCommand.relativeLineTo, [10.0, -10.0]),
          PathNode(
            PathDataCommand.relativeArcTo,
            [30.0, 50.0, -45.0, false, true, 42.55, -42.55],
          ),
          PathNode(PathDataCommand.relativeLineTo, [99.9, -99.9]),
        ];
        final actualPathNodes = parsePathData(pathData);
        expect(actualPathNodes, orderedEquals(expectedPathNodes));
      });
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
        final actualPathNodes = parsePathData(pathData);
        expect(actualPathNodes, orderedEquals(expectedPathNodes));
      });
    });
  });
}
