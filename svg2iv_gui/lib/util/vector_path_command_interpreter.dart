import 'dart:ui';

import 'package:svg2iv_common/models.dart';

void interpretPathCommands(List<PathNode> pathNodes, Path path) {
  path.reset();

  for (final pathNode in pathNodes) {
    switch (pathNode.command) {
      case PathDataCommand.moveTo:
        final arguments = pathNode.arguments.cast<double>();
        path.moveTo(arguments[0], arguments[1]);
        break;
      case PathDataCommand.lineTo:
        final arguments = pathNode.arguments.cast<double>();
        path.lineTo(arguments[0], arguments[1]);
        break;
      case PathDataCommand.curveTo:
        final arguments = pathNode.arguments.cast<double>();
        path.cubicTo(
          arguments[0],
          arguments[1],
          arguments[2],
          arguments[3],
          arguments[4],
          arguments[5],
        );
        break;
      case PathDataCommand.arcTo:
        final arguments = pathNode.arguments;
        final largeArc = arguments[3] as bool;
        final clockwise = arguments[4] as bool;
        final argumentsWithoutFlags =
            (arguments.toList()..removeRange(3, 5)).cast<double>();
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
        break;
      case PathDataCommand.close:
        path.close();
        break;
    }
  }
}
