import 'dart:collection';

import 'package:svg2iv_common/extensions.dart';
import 'package:svg2iv_common/models.dart';
import 'package:svg2iv_common/src/file_parser.dart';
import 'package:tuple/tuple.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart' as vgc;

ImageVector parseSvgElement(String xml) {
  final vgc.VectorInstructions instructions;
  try {
    instructions = vgc.parseWithoutOptimizers(xml);
  } on StateError catch (e) {
    throw ParserException(e.message);
  }
  return ImageVectorBuilder(instructions.width, instructions.height)
      .addNodes(_mapInstructions(instructions))
      .build();
}

Iterable<VectorNode> _mapInstructions(vgc.VectorInstructions instructions) {
  final vectorNodes = <VectorNode>[];
  final groupBuilderStack = Queue<VectorGroupBuilder>();
  final supportedCommands = instructions.commands.where((command) =>
      command.type == vgc.DrawCommandType.path ||
      command.type == vgc.DrawCommandType.clip ||
      command.type == vgc.DrawCommandType.restore);
  for (final command in supportedCommands) {
    switch (command.type) {
      case vgc.DrawCommandType.path:
        final path = _mapPath(
          instructions.paths[command.objectId!],
          command.paintId?.let((id) => instructions.paints[id]),
        );
        if (groupBuilderStack.isNotEmpty) {
          groupBuilderStack.last.addNode(path);
        } else {
          vectorNodes.add(path);
        }
        break;
      case vgc.DrawCommandType.clip:
        final pathNodes = _mapPathCommands(
          instructions.paths[command.objectId!],
        );
        groupBuilderStack.addLast(
          VectorGroupBuilder().clipPathData(pathNodes),
        );
        break;
      case vgc.DrawCommandType.restore:
        final group = groupBuilderStack.removeLast().build();
        if (groupBuilderStack.isNotEmpty) {
          groupBuilderStack.last.addNode(group);
        } else {
          vectorNodes.add(group);
        }
        break;
      default:
        break;
    }
  }
  return vectorNodes;
}

VectorPath _mapPath(vgc.Path path, vgc.Paint? paint) {
  final pathBuilder = VectorPathBuilder(_mapPathCommands(path))
      .pathFillType(_mapPathFillType(path.fillType));
  if (paint != null) {
    final fill = paint.fill?.let(_mapFill);
    if (fill != null) {
      pathBuilder.fill(fill.item1);
      pathBuilder.fillAlpha(fill.item2);
    }
    final stroke = paint.stroke?.let(_mapStroke);
    if (stroke != null) {
      pathBuilder.stroke(stroke.item1);
      pathBuilder.strokeAlpha(stroke.item2);
      paint.stroke!.cap?.let((strokeCap) {
        pathBuilder.strokeLineCap(_mapStrokeCap(strokeCap));
      });
      paint.stroke!.join?.let((strokeJoin) {
        pathBuilder.strokeLineJoin(_mapStrokeJoin(strokeJoin));
      });
      paint.stroke!.miterLimit?.let(pathBuilder.strokeLineMiter);
      paint.stroke!.width?.let(pathBuilder.strokeLineWidth);
    }
  }
  return pathBuilder.build();
}

List<PathNode> _mapPathCommands(vgc.Path path) {
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

PathFillType _mapPathFillType(vgc.PathFillType type) =>
    type == vgc.PathFillType.nonZero
        ? PathFillType.nonZero
        : PathFillType.evenOdd;

Tuple2<Brush, double> _mapFill(vgc.Fill fill) =>
    _mapGradient(fill.shader, fill.color);

Tuple2<Brush, double> _mapStroke(vgc.Stroke stroke) =>
    _mapGradient(stroke.shader, stroke.color);

Tuple2<Brush, double> _mapGradient(vgc.Gradient? shader, vgc.Color color) {
  final Brush brush;
  if (shader != null && !shader.colors.isNullOrEmpty) {
    if (shader is vgc.RadialGradient) {
      brush = RadialGradient(
        shader.colors!.map((color) => color.value).toNonGrowableList(),
        stops: shader.offsets,
        centerX: shader.center.x,
        centerY: shader.center.y,
        radius: shader.radius,
        tileMode: _mapTileMode(shader.tileMode),
      );
    } else {
      shader as vgc.LinearGradient;
      brush = LinearGradient(
        shader.colors!.map((color) => color.value).toNonGrowableList(),
        stops: shader.offsets,
        startX: shader.from.x,
        startY: shader.from.y,
        endX: shader.to.x,
        endY: shader.to.y,
        tileMode: _mapTileMode(shader.tileMode),
      );
    }
  } else {
    // opacity is handled separately
    brush = SolidColor((color.value << 8) >> 8);
  }
  return Tuple2(brush, color.a / 0xFF);
}

TileMode? _mapTileMode(vgc.TileMode? mode) {
  switch (mode) {
    case vgc.TileMode.clamp:
      return TileMode.clamp;
    case vgc.TileMode.repeated:
      return TileMode.repeated;
    case vgc.TileMode.mirror:
      return TileMode.mirror;
    default:
      return null;
  }
}

StrokeCap _mapStrokeCap(vgc.StrokeCap cap) {
  switch (cap) {
    case vgc.StrokeCap.butt:
      return StrokeCap.butt;
    case vgc.StrokeCap.round:
      return StrokeCap.round;
    case vgc.StrokeCap.square:
      return StrokeCap.square;
  }
}

StrokeJoin _mapStrokeJoin(vgc.StrokeJoin join) {
  switch (join) {
    case vgc.StrokeJoin.miter:
      return StrokeJoin.miter;
    case vgc.StrokeJoin.round:
      return StrokeJoin.round;
    case vgc.StrokeJoin.bevel:
      return StrokeJoin.bevel;
  }
}
