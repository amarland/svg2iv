import 'dart:ui';

import 'package:svg2iv_common/models.dart';

void interpretPathCommands(List<PathNode> pathNodes, Path path) {
  path.reset();

  for (final node in pathNodes) {
    switch (node) {
      case MoveToNode():
        path.moveTo(node.x, node.y);
        break;
      case LineToNode():
        path.lineTo(node.x, node.y);
        break;
      case CurveToNode():
        path.cubicTo(node.x1, node.y1, node.x2, node.y2, node.x3, node.y3);
        break;
      case ArcToNode():
        path.arcToPoint(
          Offset(node.x, node.y),
          radius: Radius.elliptical(node.rx, node.ry),
          rotation: node.angle,
          largeArc: node.largeArc,
          clockwise: node.sweep,
        );
        break;
      case CloseNode():
        path.close();
        break;
    }
  }
}
