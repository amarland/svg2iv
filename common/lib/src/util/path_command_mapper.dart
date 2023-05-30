import 'package:svg2iv_common/extensions.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart' as vgc;

import '../model/vector_path.dart';

List<PathNode> mapPathCommands(vgc.Path path) {
  return path.commands.map((command) {
    switch (command.type) {
      case vgc.PathCommandType.move:
        final moveToCommand = command as vgc.MoveToCommand;
        return PathNode(
          PathDataCommand.moveTo,
          [moveToCommand.x, moveToCommand.y],
        );
      case vgc.PathCommandType.line:
        final lineToCommand = command as vgc.LineToCommand;
        return PathNode(
          PathDataCommand.lineTo,
          [lineToCommand.x, lineToCommand.y],
        );
      case vgc.PathCommandType.cubic:
        final cubicToCommand = command as vgc.CubicToCommand;
        return PathNode(
          PathDataCommand.curveTo,
          [
            cubicToCommand.controlPoint1.x,
            cubicToCommand.controlPoint1.y,
            cubicToCommand.controlPoint2.x,
            cubicToCommand.controlPoint2.y
          ],
        );
      case vgc.PathCommandType.close:
        return PathNode(PathDataCommand.close, List.empty());
    }
  }).toNonGrowableList();
}
