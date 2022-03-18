import 'dart:ui';

import 'package:svg2iv_common/model/vector_path.dart';
import 'package:vector_math/vector_math.dart';

void interpretPathCommands(List<PathNode> pathNodes, Path path) {
  path.reset();
  final currentPoint = Vector2.zero();
  final controlPoint = Vector2.zero();
  final segmentPoint = Vector2.zero();
  final reflectiveControlPoint = Vector2.zero();
  var isPreviousNodeACurve = false;

  void _onMoveToCommandReceived(List<dynamic> arguments) {
    path.moveTo(arguments[0], arguments[1]);
    currentPoint.x = arguments[0];
    currentPoint.y = arguments[1];
    segmentPoint.x = currentPoint.x;
    segmentPoint.y = currentPoint.y;
    isPreviousNodeACurve = false;
  }

  void _onRelativeMoveToCommandReceived(List<dynamic> arguments) {
    path.relativeMoveTo(arguments[0], arguments[1]);
    currentPoint.x += arguments[0];
    currentPoint.y += arguments[1];
    segmentPoint.x = currentPoint.x;
    segmentPoint.y = currentPoint.y;
    isPreviousNodeACurve = false;
  }

  void _onLineToCommandReceived(List<dynamic> arguments) {
    path.lineTo(arguments[0], arguments[1]);
    currentPoint.x = arguments[0];
    currentPoint.y = arguments[1];
    isPreviousNodeACurve = false;
  }

  void _onRelativeLineToCommandReceived(List<dynamic> arguments) {
    path.relativeLineTo(arguments[0], arguments[1]);
    currentPoint.x += arguments[0];
    currentPoint.y += arguments[1];
    isPreviousNodeACurve = false;
  }

  void _onHorizontalLineToCommandReceived(List<dynamic> arguments) {
    path.lineTo(arguments[0], currentPoint.y);
    currentPoint.x = arguments[0];
    isPreviousNodeACurve = false;
  }

  void _onRelativeHorizontalLineToCommandReceived(List<dynamic> arguments) {
    path.relativeLineTo(arguments[0], 0);
    currentPoint.x += arguments[0];
    isPreviousNodeACurve = false;
  }

  void _onVerticalLineToCommandReceived(List<dynamic> arguments) {
    path.lineTo(currentPoint.x, arguments[0]);
    currentPoint.y = arguments[0];
    isPreviousNodeACurve = false;
  }

  void _onRelativeVerticalLineToCommandReceived(List<dynamic> arguments) {
    path.relativeLineTo(0, arguments[0]);
    currentPoint.y += arguments[0];
    isPreviousNodeACurve = false;
  }

  void _onCurveToCommandReceived(List<dynamic> arguments) {
    path.cubicTo(
      arguments[0],
      arguments[1],
      arguments[2],
      arguments[3],
      arguments[4],
      arguments[5],
    );
    controlPoint.x = arguments[2];
    controlPoint.y = arguments[3];
    currentPoint.x = arguments[4];
    currentPoint.y = arguments[5];
    isPreviousNodeACurve = true;
  }

  void _onRelativeCurveToCommandReceived(List<dynamic> arguments) {
    path.relativeCubicTo(
      arguments[0],
      arguments[1],
      arguments[2],
      arguments[3],
      arguments[4],
      arguments[5],
    );
    controlPoint.x = currentPoint.x + arguments[2];
    controlPoint.y = currentPoint.y + arguments[3];
    currentPoint.x += arguments[4];
    currentPoint.y += arguments[5];
    isPreviousNodeACurve = true;
  }

  void _onSmoothCurveToCommandReceived(List<dynamic> arguments) {
    if (isPreviousNodeACurve) {
      reflectiveControlPoint.x = 2 * currentPoint.x - controlPoint.x;
      reflectiveControlPoint.y = 2 * currentPoint.y - controlPoint.y;
    } else {
      reflectiveControlPoint.x = currentPoint.x;
      reflectiveControlPoint.y = currentPoint.y;
    }
    path.cubicTo(
      reflectiveControlPoint.x,
      reflectiveControlPoint.y,
      arguments[0],
      arguments[1],
      arguments[2],
      arguments[3],
    );
    controlPoint.x = arguments[0];
    controlPoint.y = arguments[1];
    currentPoint.x = arguments[2];
    currentPoint.y = arguments[3];
    isPreviousNodeACurve = true;
  }

  void _onRelativeSmoothCurveToCommandReceived(List<dynamic> arguments) {
    if (isPreviousNodeACurve) {
      reflectiveControlPoint.x = currentPoint.x - controlPoint.x;
      reflectiveControlPoint.y = currentPoint.y - controlPoint.y;
    } else {
      reflectiveControlPoint.x = 0.0;
      reflectiveControlPoint.y = 0.0;
    }
    path.relativeCubicTo(
      reflectiveControlPoint.x,
      reflectiveControlPoint.y,
      arguments[0],
      arguments[1],
      arguments[2],
      arguments[3],
    );
    controlPoint.x = currentPoint.x + arguments[0];
    controlPoint.y = currentPoint.y + arguments[1];
    currentPoint.x += arguments[2];
    currentPoint.y += arguments[3];
    isPreviousNodeACurve = true;
  }

  void _onQuadToCommandReceived(List<dynamic> arguments) {
    path.quadraticBezierTo(
      arguments[0],
      arguments[1],
      arguments[2],
      arguments[3],
    );
    controlPoint.x = arguments[0];
    controlPoint.y = arguments[1];
    currentPoint.x = arguments[2];
    currentPoint.y = arguments[3];
    isPreviousNodeACurve = true;
  }

  void _onRelativeQuadToCommandReceived(List<dynamic> arguments) {
    path.relativeQuadraticBezierTo(
      arguments[0],
      arguments[1],
      arguments[2],
      arguments[3],
    );
    controlPoint.x = currentPoint.x + arguments[0];
    controlPoint.y = currentPoint.y + arguments[1];
    currentPoint.x += arguments[2];
    currentPoint.y += arguments[3];
    isPreviousNodeACurve = true;
  }

  void _onSmoothQuadToCommandReceived(List<dynamic> arguments) {
    if (isPreviousNodeACurve) {
      reflectiveControlPoint.x = 2 * currentPoint.x - controlPoint.x;
      reflectiveControlPoint.y = 2 * currentPoint.y - controlPoint.y;
    } else {
      reflectiveControlPoint.x = currentPoint.x;
      reflectiveControlPoint.y = currentPoint.y;
    }
    path.quadraticBezierTo(
      reflectiveControlPoint.x,
      reflectiveControlPoint.y,
      arguments[0],
      arguments[1],
    );
    controlPoint.x = reflectiveControlPoint.x;
    controlPoint.y = reflectiveControlPoint.y;
    currentPoint.x = arguments[0];
    currentPoint.y = arguments[1];
    isPreviousNodeACurve = true;
  }

  void _onRelativeSmoothQuadToCommandReceived(List<dynamic> arguments) {
    if (isPreviousNodeACurve) {
      reflectiveControlPoint.x = currentPoint.x - controlPoint.x;
      reflectiveControlPoint.y = currentPoint.y - controlPoint.y;
    } else {
      reflectiveControlPoint.x = 0.0;
      reflectiveControlPoint.y = 0.0;
    }
    path.relativeQuadraticBezierTo(
      reflectiveControlPoint.x,
      reflectiveControlPoint.y,
      arguments[0],
      arguments[1],
    );
    controlPoint.x = currentPoint.x + reflectiveControlPoint.x;
    controlPoint.y = currentPoint.y + reflectiveControlPoint.y;
    currentPoint.x += arguments[0];
    currentPoint.y += arguments[1];
    isPreviousNodeACurve = true;
  }

  void _onArcToCommandReceived(List<dynamic> arguments) {
    path.arcToPoint(
      Offset(arguments[5], arguments[6]),
      radius: Radius.elliptical(arguments[0], arguments[1]),
      rotation: arguments[2],
      largeArc: arguments[3],
      clockwise: arguments[4],
    );
    controlPoint.x = currentPoint.x = arguments[5];
    controlPoint.y = currentPoint.y = arguments[6];
    isPreviousNodeACurve = false;
  }

  void _onRelativeArcToCommandReceived(List<dynamic> arguments) {
    path.relativeArcToPoint(
      Offset(arguments[5], arguments[6]),
      radius: Radius.elliptical(arguments[0], arguments[1]),
      rotation: arguments[2],
      largeArc: arguments[3],
      clockwise: arguments[4],
    );
    controlPoint.x = currentPoint.x = arguments[5];
    controlPoint.y = currentPoint.y = arguments[6];
    isPreviousNodeACurve = false;
  }

  void _onCloseCommandReceived() {
    currentPoint.x = segmentPoint.x;
    currentPoint.y = segmentPoint.y;
    controlPoint.x = segmentPoint.x;
    controlPoint.y = segmentPoint.y;
    path.close();
    isPreviousNodeACurve = false;
  }

  for (final pathNode in pathNodes) {
    final arguments = pathNode.arguments;
    switch (pathNode.command) {
      case PathDataCommand.moveTo:
        _onMoveToCommandReceived(arguments);
        break;
      case PathDataCommand.relativeMoveTo:
        _onRelativeMoveToCommandReceived(arguments);
        break;
      case PathDataCommand.lineTo:
        _onLineToCommandReceived(arguments);
        break;
      case PathDataCommand.relativeLineTo:
        _onRelativeLineToCommandReceived(arguments);
        break;
      case PathDataCommand.horizontalLineTo:
        _onHorizontalLineToCommandReceived(arguments);
        break;
      case PathDataCommand.relativeHorizontalLineTo:
        _onRelativeHorizontalLineToCommandReceived(arguments);
        break;
      case PathDataCommand.verticalLineTo:
        _onVerticalLineToCommandReceived(arguments);
        break;
      case PathDataCommand.relativeVerticalLineTo:
        _onRelativeVerticalLineToCommandReceived(arguments);
        break;
      case PathDataCommand.curveTo:
        _onCurveToCommandReceived(arguments);
        break;
      case PathDataCommand.relativeCurveTo:
        _onRelativeCurveToCommandReceived(arguments);
        break;
      case PathDataCommand.smoothCurveTo:
        _onSmoothCurveToCommandReceived(arguments);
        break;
      case PathDataCommand.relativeSmoothCurveTo:
        _onRelativeSmoothCurveToCommandReceived(arguments);
        break;
      case PathDataCommand.quadraticBezierCurveTo:
        _onQuadToCommandReceived(arguments);
        break;
      case PathDataCommand.relativeQuadraticBezierCurveTo:
        _onRelativeQuadToCommandReceived(arguments);
        break;
      case PathDataCommand.smoothQuadraticBezierCurveTo:
        _onSmoothQuadToCommandReceived(arguments);
        break;
      case PathDataCommand.relativeSmoothQuadraticBezierCurveTo:
        _onRelativeSmoothQuadToCommandReceived(arguments);
        break;
      case PathDataCommand.arcTo:
        _onArcToCommandReceived(arguments);
        break;
      case PathDataCommand.relativeArcTo:
        _onRelativeArcToCommandReceived(arguments);
        break;
      case PathDataCommand.close:
        _onCloseCommandReceived();
        break;
    }
  }
}
