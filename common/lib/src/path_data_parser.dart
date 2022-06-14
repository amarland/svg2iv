import 'package:collection/collection.dart';
import 'package:path_parsing/path_parsing.dart';

import 'extensions.dart';
import 'model/transformations.dart';
import 'model/vector_path.dart';

List<PathNode> parsePathData(
  String? pathData, {
  Translation? translation,
  bool shouldNormalize = false,
}) {
  if (pathData == null) return List.empty();
  final segments = SvgPathStringSource(pathData).parseSegments();
  translation = translation.orDefault();
  final offsetX = translation.x;
  final offsetY = translation.y;
  if (shouldNormalize) {
    final proxy = _PathProxy(offsetX, offsetY);
    for (final segment in segments) {
      SvgPathNormalizer().emitSegment(segment, proxy);
    }
    return proxy.pathNodes;
  } else {
    return segments
        .map((segment) {
          // _SvgPathSegType is inaccessible, so we rely on enum indices
          final enumIndex = segment.command.index;
          final areCoordinatesAbsolute = enumIndex.isEven; // except for 1 and 2
          final adjustedPoint1 = areCoordinatesAbsolute
              ? segment.point1.translate(offsetX, offsetY)
              : segment.point1;
          final adjustedPoint2 = areCoordinatesAbsolute
              ? segment.point2.translate(offsetX, offsetY)
              : segment.point2;
          final adjustedTargetPoint = areCoordinatesAbsolute
              ? segment.targetPoint.translate(offsetX, offsetY)
              : segment.targetPoint;
          switch (enumIndex) {
            case 0: // SvgPathSegType.unknown:
              return null;
            case 1: // SvgPathSegType.close:
              return PathNode(PathDataCommand.close, List.empty());
            case 2: // SvgPathSegType.moveToAbs:
            case 3: // SvgPathSegType.moveToRel:
              final command = areCoordinatesAbsolute
                  ? PathDataCommand.moveTo
                  : PathDataCommand.relativeMoveTo;
              return PathNode(
                command,
                [adjustedTargetPoint.dx, adjustedTargetPoint.dy],
              );
            case 4: // SvgPathSegType.lineToAbs:
            case 5: // SvgPathSegType.lineToRel:
              final command = areCoordinatesAbsolute
                  ? PathDataCommand.lineTo
                  : PathDataCommand.relativeLineTo;
              return PathNode(
                command,
                [adjustedTargetPoint.dx, adjustedTargetPoint.dy],
              );
            case 6: // SvgPathSegType.cubicToAbs:
            case 7: // SvgPathSegType.cubicToRel:
              final command = areCoordinatesAbsolute
                  ? PathDataCommand.curveTo
                  : PathDataCommand.relativeCurveTo;
              return PathNode(command, [
                adjustedPoint1.dx,
                adjustedPoint1.dy,
                adjustedPoint2.dx,
                adjustedPoint2.dy,
                adjustedTargetPoint.dx,
                adjustedTargetPoint.dy
              ]);
            case 8: // SvgPathSegType.quadToAbs:
            case 9: // SvgPathSegType.quadToRel:
              final command = areCoordinatesAbsolute
                  ? PathDataCommand.quadraticBezierCurveTo
                  : PathDataCommand.relativeQuadraticBezierCurveTo;
              return PathNode(
                command,
                [
                  adjustedPoint1.dx,
                  adjustedPoint1.dy,
                  adjustedTargetPoint.dx,
                  adjustedTargetPoint.dy,
                ],
              );
            case 10: // SvgPathSegType.arcToAbs:
            case 11: // SvgPathSegType.arcToRel:
              final command = areCoordinatesAbsolute
                  ? PathDataCommand.arcTo
                  : PathDataCommand.relativeArcTo;
              return PathNode(
                command,
                [
                  // don't adjust these two, they specify the x-/y-radius
                  segment.point1.dx,
                  segment.point1.dy,
                  segment.arcAngle,
                  segment.arcLarge,
                  segment.arcSweep,
                  adjustedTargetPoint.dx,
                  adjustedTargetPoint.dy,
                ],
              );
            case 12: // SvgPathSegType.lineToHorizontalAbs:
            case 13: // SvgPathSegType.lineToHorizontalRel:
              final command = areCoordinatesAbsolute
                  ? PathDataCommand.horizontalLineTo
                  : PathDataCommand.relativeHorizontalLineTo;
              return PathNode(command, [adjustedTargetPoint.dx]);
            case 14: // SvgPathSegType.lineToVerticalAbs:
            case 15: // SvgPathSegType.lineToVerticalRel:
              final command = areCoordinatesAbsolute
                  ? PathDataCommand.verticalLineTo
                  : PathDataCommand.relativeVerticalLineTo;
              return PathNode(command, [adjustedTargetPoint.dy]);
            case 16: // SvgPathSegType.smoothCubicToAbs:
            case 17: // SvgPathSegType.smoothCubicToRel:
              final command = areCoordinatesAbsolute
                  ? PathDataCommand.smoothCurveTo
                  : PathDataCommand.relativeSmoothCurveTo;
              return PathNode(
                command,
                [
                  adjustedPoint2.dx,
                  adjustedPoint2.dy,
                  adjustedTargetPoint.dx,
                  adjustedTargetPoint.dy,
                ],
              );
            case 18: // SvgPathSegType.smoothQuadToAbs:
            case 19: // SvgPathSegType.smoothQuadToRel:
              final command = areCoordinatesAbsolute
                  ? PathDataCommand.smoothQuadraticBezierCurveTo
                  : PathDataCommand.relativeSmoothQuadraticBezierCurveTo;
              return PathNode(
                command,
                [adjustedTargetPoint.dx, adjustedTargetPoint.dy],
              );
          }
        })
        .whereNotNull()
        .toNonGrowableList();
  }
}

class _PathProxy implements PathProxy {
  _PathProxy(this.offsetX, this.offsetY);

  final pathNodes = <PathNode>[];

  final double offsetX;
  final double offsetY;

  @override
  void close() {
    pathNodes.add(PathNode(PathDataCommand.close, List.empty()));
  }

  @override
  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    pathNodes.add(
      PathNode(
        PathDataCommand.curveTo,
        [
          x1 + offsetX,
          y1 + offsetY,
          x2 + offsetX,
          y2 + offsetY,
          x3 + offsetX,
          y3 + offsetY,
        ],
      ),
    );
  }

  @override
  void lineTo(double x, double y) {
    pathNodes.add(
      PathNode(
        PathDataCommand.lineTo,
        [x + offsetX, y + offsetY],
      ),
    );
  }

  @override
  void moveTo(double x, double y) {
    pathNodes.add(
      PathNode(
        PathDataCommand.moveTo,
        [x + offsetX, y + offsetY],
      ),
    );
  }
}
