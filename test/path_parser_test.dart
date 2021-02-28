/*
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:svg2iv/image_vector.dart';
import 'package:svg2iv/path_parser.dart';
import 'package:svg_path_parser/svg_path_parser.dart' as third_party;

void main() {
  test(
    'PathParser.parse() returns an object whose pathNodes'
    ' can be used to build a Path equal to the one'
    ' returned by the parse() method of its inner Parser',
    () {
      final paths = const [
        'M3,3m2,2h90v90h-90l0,-90',
        'M5,5H95V95H5L5,5',
        'M10,80c30,-70,55,-70,85,0s55,70,85,0',
        'M10,80C40,10,65,10,95,80S150,150,180,80',
        'M10,80q42.5,-70,85,0t85,0',
        'M10,80Q52.5,10,95,80T180,80',
        'M10,315l100,-100a30,50,0,0,1,52.55,-52.55l10,-10'
            'a30,50,-45,0,1,42.55,-42.55l99.9,-99.9',
        'M10,315L110,215A30,50,0,0,1,162.55,162.45L172.55,152.45'
            'A30,50,-45,0,1,215.1,109.9L315,10',
      ];
      final expectedPaths =
          paths.map((path) => third_party.Parser(path).parse()).toList();
      final iterableOfpathNodes =
          paths.map((path) => PathParser(path).parse()?.pathNodes);
      final actualPaths = iterableOfpathNodes
          .map((pathNodes) => _pathFrompathNodes(pathNodes))
          .toList();
      final actualPathCount = actualPaths.length;
      expect(actualPathCount, expectedPaths.length);
      expect(actualPaths, everyElement(isNotNull));
      for (var i = 0; i < actualPathCount; i++) {
        final actualPath = actualPaths[i]!;
        expect(
          actualPath,
          coversSameAreaAs(
            expectedPaths[i],
            areaToCompare: actualPath.getBounds(),
          ),
        );
      }
    },
  );
}

Path? _pathFrompathNodes(Iterable<PathDataInstruction>? pathNodes) {
  if (pathNodes == null || pathNodes.isEmpty) return null;
  final path = Path();
  for (final instruction in pathNodes) {
    final arguments = instruction.arguments;
    switch (instruction.command) {
      case PathDataCommand.moveTo:
        path.moveTo(arguments[0], arguments[1]);
        break;
      case PathDataCommand.relativeMoveTo:
        path.relativeMoveTo(arguments[0], arguments[1]);
        break;
      case PathDataCommand.lineTo:
      case PathDataCommand.horizontalLineTo:
      case PathDataCommand.verticalLineTo:
        path.lineTo(arguments[0], arguments[1]);
        break;
      case PathDataCommand.relativeLineTo:
      case PathDataCommand.relativeHorizontalLineTo:
      case PathDataCommand.relativeVerticalLineTo:
        path.relativeLineTo(arguments[0], arguments[1]);
        break;
      case PathDataCommand.curveTo:
      case PathDataCommand.smoothCurveTo:
        path.cubicTo(
          arguments[0],
          arguments[1],
          arguments[2],
          arguments[3],
          arguments[4],
          arguments[5],
        );
        break;
      case PathDataCommand.relativeCurveTo:
      case PathDataCommand.relativeSmoothCurveTo:
        path.relativeCubicTo(
          arguments[0],
          arguments[1],
          arguments[2],
          arguments[3],
          arguments[4],
          arguments[5],
        );
        break;
      case PathDataCommand.quadraticBezierCurveTo:
      case PathDataCommand.smoothQuadraticBezierCurveTo:
        path.quadraticBezierTo(
          arguments[0],
          arguments[1],
          arguments[2],
          arguments[3],
        );
        break;
      case PathDataCommand.relativeQuadraticBezierCurveTo:
      case PathDataCommand.relativeSmoothQuadraticBezierCurveTo:
        path.relativeQuadraticBezierTo(
          arguments[0],
          arguments[1],
          arguments[2],
          arguments[3],
        );
        break;
      case PathDataCommand.arcTo:
        path.arcToPoint(
          arguments[0],
          radius: arguments[1],
          rotation: arguments[2],
          largeArc: arguments[3],
          clockwise: arguments[4],
        );
        break;
      case PathDataCommand.relativeArcTo:
        path.relativeArcToPoint(
          arguments[0],
          radius: arguments[1],
          rotation: arguments[2],
          largeArc: arguments[3],
          clockwise: arguments[4],
        );
        break;
      case PathDataCommand.close:
        path.close();
        break;
    }
  }
  return path;
}
*/
