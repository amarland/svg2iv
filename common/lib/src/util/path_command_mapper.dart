import 'package:svg2iv_common/extensions.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart' as vgc;

import '../model/path_node.dart';

List<PathNode> mapPathCommands(vgc.Path path) {
  return path.commands.map((command) {
    switch (command.type) {
      case vgc.PathCommandType.move:
        final moveToCommand = command as vgc.MoveToCommand;
        return MoveToNode(moveToCommand.x, moveToCommand.y);
      case vgc.PathCommandType.line:
        final lineToCommand = command as vgc.LineToCommand;
        return LineToNode(lineToCommand.x, lineToCommand.y);
      case vgc.PathCommandType.cubic:
        final cubicToCommand = command as vgc.CubicToCommand;
        return CurveToNode(
          cubicToCommand.x1,
          cubicToCommand.y1,
          cubicToCommand.x2,
          cubicToCommand.y2,
          cubicToCommand.x3,
          cubicToCommand.y3,
        );
      case vgc.PathCommandType.close:
        return const CloseNode();
    }
  }).toNonGrowableList();
}
