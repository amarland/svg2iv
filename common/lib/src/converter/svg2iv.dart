import 'dart:collection';

import 'package:svg2iv_common/extensions.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart' as vgc;
import 'package:xml/xml_events.dart';

import '../../models.dart';
import '../file_parser.dart';
import '../util/path_command_mapper.dart';

ImageVector parseSvgElement(String xml, {String? sourceName}) {
  final vgc.VectorInstructions instructions;
  try {
    instructions = vgc.parseWithoutOptimizers(xml);
  } on StateError catch (e) {
    throw ParserException(e.message);
  }
  final builder = ImageVectorBuilder(instructions.width, instructions.height);
  sourceName ??= parseEvents(xml)
      .whereType<XmlStartElementEvent>()
      .firstOrNull
      ?.attributes
      .singleWhereOrNull((a) => a.localName == 'id')
      ?.value;
  sourceName?.let(builder.name);
  for (final vectorNode in _mapInstructions(instructions)) {
    builder.addNode(vectorNode);
  }
  return builder.build();
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
        final pathNodes = mapPathCommands(
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
  final pathBuilder = VectorPathBuilder(mapPathCommands(path))
      .pathFillType(_mapPathFillType(path.fillType));
  if (paint != null) {
    final fill = paint.fill?.let(_mapFill);
    if (fill != null) {
      final (brush, alpha) = fill;
      pathBuilder.fill(brush);
      pathBuilder.fillAlpha(alpha);
    }
    final stroke = paint.stroke?.let(_mapStroke);
    if (stroke != null) {
      final (brush, alpha) = stroke;
      pathBuilder.stroke(brush);
      pathBuilder.strokeAlpha(alpha);
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

PathFillType _mapPathFillType(vgc.PathFillType type) =>
    type == vgc.PathFillType.nonZero
        ? PathFillType.nonZero
        : PathFillType.evenOdd;

(Brush, double) _mapFill(vgc.Fill fill) =>
    _mapGradient(fill.shader, fill.color);

(Brush, double) _mapStroke(vgc.Stroke stroke) =>
    _mapGradient(stroke.shader, stroke.color);

(Brush, double) _mapGradient(vgc.Gradient? shader, vgc.Color color) {
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
    brush = SolidColor(color.value & 0x00FFFFFF + 0xFF000000);
  }
  return (brush, color.a / 0xFF);
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
