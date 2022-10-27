import 'dart:ui';

import 'package:svg2iv_common/models.dart';

class _Point {
  double x = 0.0, y = 0.0;
}

void interpretPathCommands(List<PathNode> pathNodes, Path path) {
  path.reset();
  final currentPoint = _Point();
  final controlPoint = _Point();
  final segmentPoint = _Point();
  final reflectiveControlPoint = _Point();
  var isPreviousNodeACurve = false;

  void onMoveToCommandReceived(List<double> arguments) {
    path.moveTo(arguments[0], arguments[1]);
    currentPoint.x = arguments[0];
    currentPoint.y = arguments[1];
    segmentPoint.x = currentPoint.x;
    segmentPoint.y = currentPoint.y;
    isPreviousNodeACurve = false;
  }

  void onRelativeMoveToCommandReceived(List<double> arguments) {
    path.relativeMoveTo(arguments[0], arguments[1]);
    currentPoint.x += arguments[0];
    currentPoint.y += arguments[1];
    segmentPoint.x = currentPoint.x;
    segmentPoint.y = currentPoint.y;
    isPreviousNodeACurve = false;
  }

  void onLineToCommandReceived(List<double> arguments) {
    path.lineTo(arguments[0], arguments[1]);
    currentPoint.x = arguments[0];
    currentPoint.y = arguments[1];
    isPreviousNodeACurve = false;
  }

  void onRelativeLineToCommandReceived(List<double> arguments) {
    path.relativeLineTo(arguments[0], arguments[1]);
    currentPoint.x += arguments[0];
    currentPoint.y += arguments[1];
    isPreviousNodeACurve = false;
  }

  void onHorizontalLineToCommandReceived(List<double> arguments) {
    path.lineTo(arguments[0], currentPoint.y);
    currentPoint.x = arguments[0];
    isPreviousNodeACurve = false;
  }

  void onRelativeHorizontalLineToCommandReceived(List<double> arguments) {
    path.relativeLineTo(arguments[0], 0);
    currentPoint.x += arguments[0];
    isPreviousNodeACurve = false;
  }

  void onVerticalLineToCommandReceived(List<double> arguments) {
    path.lineTo(currentPoint.x, arguments[0]);
    currentPoint.y = arguments[0];
    isPreviousNodeACurve = false;
  }

  void onRelativeVerticalLineToCommandReceived(List<double> arguments) {
    path.relativeLineTo(0, arguments[0]);
    currentPoint.y += arguments[0];
    isPreviousNodeACurve = false;
  }

  void onCurveToCommandReceived(List<double> arguments) {
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

  void onRelativeCurveToCommandReceived(List<double> arguments) {
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

  void onSmoothCurveToCommandReceived(List<double> arguments) {
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

  void onRelativeSmoothCurveToCommandReceived(List<double> arguments) {
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

  void onQuadToCommandReceived(List<double> arguments) {
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

  void onRelativeQuadToCommandReceived(List<double> arguments) {
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

  void onSmoothQuadToCommandReceived(List<double> arguments) {
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

  void onRelativeSmoothQuadToCommandReceived(List<double> arguments) {
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

  void onArcToCommandReceived(
    List<double> argumentsWithoutFlags,
    bool largeArc,
    bool clockwise,
  ) {
    path.arcToPoint(
      Offset(argumentsWithoutFlags[3], argumentsWithoutFlags[4]),
      radius: Radius.elliptical(
        argumentsWithoutFlags[0],
        argumentsWithoutFlags[1],
      ),
      rotation: argumentsWithoutFlags[2],
      largeArc: largeArc,
      clockwise: clockwise,
    );
    controlPoint.x = currentPoint.x = argumentsWithoutFlags[3];
    controlPoint.y = currentPoint.y = argumentsWithoutFlags[4];
    isPreviousNodeACurve = false;
  }

  void onRelativeArcToCommandReceived(
    List<double> argumentsWithoutFlags,
    bool largeArc,
    bool clockwise,
  ) {
    path.relativeArcToPoint(
      Offset(argumentsWithoutFlags[3], argumentsWithoutFlags[4]),
      radius: Radius.elliptical(
        argumentsWithoutFlags[0],
        argumentsWithoutFlags[1],
      ),
      rotation: argumentsWithoutFlags[2],
      largeArc: largeArc,
      clockwise: clockwise,
    );
    controlPoint.x = currentPoint.x = argumentsWithoutFlags[3];
    controlPoint.y = currentPoint.y = argumentsWithoutFlags[4];
    isPreviousNodeACurve = false;
  }

  void onCloseCommandReceived() {
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
        onMoveToCommandReceived(arguments.cast<double>());
        break;
      case PathDataCommand.relativeMoveTo:
        onRelativeMoveToCommandReceived(arguments.cast<double>());
        break;
      case PathDataCommand.lineTo:
        onLineToCommandReceived(arguments.cast<double>());
        break;
      case PathDataCommand.relativeLineTo:
        onRelativeLineToCommandReceived(arguments.cast<double>());
        break;
      case PathDataCommand.horizontalLineTo:
        onHorizontalLineToCommandReceived(arguments.cast<double>());
        break;
      case PathDataCommand.relativeHorizontalLineTo:
        onRelativeHorizontalLineToCommandReceived(arguments.cast<double>());
        break;
      case PathDataCommand.verticalLineTo:
        onVerticalLineToCommandReceived(arguments.cast<double>());
        break;
      case PathDataCommand.relativeVerticalLineTo:
        onRelativeVerticalLineToCommandReceived(arguments.cast<double>());
        break;
      case PathDataCommand.curveTo:
        onCurveToCommandReceived(arguments.cast<double>());
        break;
      case PathDataCommand.relativeCurveTo:
        onRelativeCurveToCommandReceived(arguments.cast<double>());
        break;
      case PathDataCommand.smoothCurveTo:
        onSmoothCurveToCommandReceived(arguments.cast<double>());
        break;
      case PathDataCommand.relativeSmoothCurveTo:
        onRelativeSmoothCurveToCommandReceived(arguments.cast<double>());
        break;
      case PathDataCommand.quadraticBezierCurveTo:
        onQuadToCommandReceived(arguments.cast<double>());
        break;
      case PathDataCommand.relativeQuadraticBezierCurveTo:
        onRelativeQuadToCommandReceived(arguments.cast<double>());
        break;
      case PathDataCommand.smoothQuadraticBezierCurveTo:
        onSmoothQuadToCommandReceived(arguments.cast<double>());
        break;
      case PathDataCommand.relativeSmoothQuadraticBezierCurveTo:
        onRelativeSmoothQuadToCommandReceived(arguments.cast<double>());
        break;
      case PathDataCommand.arcTo:
        final largeArc = arguments[3] as bool;
        final clockwise = arguments[4] as bool;
        onArcToCommandReceived(
          (arguments.toList()..removeRange(3, 5)).cast<double>(),
          largeArc,
          clockwise,
        );
        break;
      case PathDataCommand.relativeArcTo:
        final largeArc = arguments[3] as bool;
        final clockwise = arguments[4] as bool;
        onRelativeArcToCommandReceived(
          (arguments.toList()..removeRange(3, 5)).cast<double>(),
          largeArc,
          clockwise,
        );
        break;
      case PathDataCommand.close:
        onCloseCommandReceived();
        break;
    }
  }
}
