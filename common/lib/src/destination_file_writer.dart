import 'dart:io';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';

import 'extensions.dart';
import 'model/brush.dart';
import 'model/image_vector.dart';
import 'model/vector_group.dart';
import 'model/vector_node.dart';
import 'model/vector_path.dart';

Future<void> writeImageVectorsToFile(
  String destinationPath,
  List<ImageVector> imageVectors, {
  String? extensionReceiver,
  String? heading,
}) async {
  if (!destinationPath.endsWith('.kt') && !destinationPath.endsWith('.kts')) {
    destinationPath += '.kt';
  }
  final file = File(destinationPath).absolute;
  final fileSink = file.openWrite();
  final pathSeparator = Platform.pathSeparator;
  final absoluteFilePath = file.path;
  final String packageName;
  final startOfPackageName =
      RegExp('src\\$pathSeparator(java|kotlin)\\$pathSeparator')
          .firstMatch(absoluteFilePath)
          ?.end;
  if (startOfPackageName == null) {
    packageName = '_your_._package_._name_';
  } else {
    final endOfPackageName = absoluteFilePath.lastIndexOfOrNull('.') ??
        absoluteFilePath.lastIndexOfOrNull(pathSeparator) ??
        absoluteFilePath.length;
    packageName =
        absoluteFilePath.substring(startOfPackageName, endOfPackageName);
  }
  writeFileContents(
    fileSink,
    imageVectors,
    packageName: packageName,
    extensionReceiver: extensionReceiver,
    heading: heading,
  );
  await fileSink.flush();
  await fileSink.close();
}

void writeFileContents(
  StringSink sink,
  List<ImageVector> imageVectors, {
  String? packageName,
  String? extensionReceiver,
  String? heading,
}) {
  if (!heading.isNullOrEmpty) {
    sink
      ..writeln(heading)
      ..writeln();
  }
  if (!packageName.isNullOrEmpty) {
    sink
      ..writeln('package $packageName')
      ..writeln();
  }
  writeImports(sink, imageVectors.whereNotNull());
  for (final imageVector in imageVectors) {
    writeImageVector(sink, imageVector, extensionReceiver);
  }
}

@visibleForTesting
void writeImports(
  StringSink sink,
  Iterable<ImageVector> imageVectors,
) {
  bool graphicsPackageNeeded = false;
  bool offsetClassNeeded = false;
  for (final imageVector in imageVectors) {
    List<VectorPath> filterPaths(Iterable<VectorNode> nodes) {
      final paths = <VectorPath>[];
      return nodes.fold(paths, (paths, node) {
        if (node is VectorGroup) {
          paths.addAll(filterPaths(node.nodes));
        } else {
          paths.add(node as VectorPath);
        }
        return paths;
      });
    }

    for (final vectorPath in filterPaths(imageVector.nodes)) {
      bool doesGradientNeedOffsetClassToBeExpressed(Brush paint) {
        if (paint is SolidColor) {
          return false;
        }
        if (paint is LinearGradient) {
          return paint.startX != LinearGradient.defaultStartX ||
              paint.endX != LinearGradient.defaultEndX ||
              paint.startY != LinearGradient.defaultStartY ||
              paint.endY != LinearGradient.defaultEndY;
        } else {
          paint as RadialGradient;
          return paint.centerX != RadialGradient.defaultCenterX ||
              paint.centerY != RadialGradient.defaultCenterY;
        }
      }

      final bool? doesFillNeedOffsetClass =
          vectorPath.fill?.let(doesGradientNeedOffsetClassToBeExpressed);
      final bool? doesStrokeNeedOffsetClass =
          vectorPath.stroke?.let(doesGradientNeedOffsetClassToBeExpressed);
      if (!graphicsPackageNeeded) {
        graphicsPackageNeeded = doesFillNeedOffsetClass != null ||
            doesStrokeNeedOffsetClass != null;
      }
      if (graphicsPackageNeeded &&
          (doesFillNeedOffsetClass == true ||
              doesStrokeNeedOffsetClass == true)) {
        offsetClassNeeded = true;
        break;
      }
    }
  }
  if (offsetClassNeeded) {
    sink.writeln('import androidx.compose.ui.geometry.Offset');
  }
  if (graphicsPackageNeeded) {
    sink.writeln('import androidx.compose.ui.graphics.*');
  }
  sink
    ..writeln('import androidx.compose.ui.graphics.vector.*')
    ..writeln('import androidx.compose.ui.unit.dp')
    ..writeln();
}

@visibleForTesting
void writeImageVector(
  StringSink sink,
  ImageVector imageVector, [
  String? extensionReceiver,
]) {
  var indentationLevel = 0;
  final extensionReceiverDeclaration =
      extensionReceiver.isNullOrEmpty ? '' : '${extensionReceiver!}.';
  final imageVectorName = (imageVector.name ?? '');
  final backingPropertyName = '_${imageVectorName.toCamelCase()}';
  sink
    ..writeln(
      'private var $backingPropertyName: ImageVector? = null',
    )
    ..writeln()
    ..writeln(
      'val $extensionReceiverDeclaration$imageVectorName: ImageVector',
    )
    ..writelnIndent(++indentationLevel, 'get() {')
    ..writelnIndent(++indentationLevel, 'if ($backingPropertyName == null) {')
    ..writelnIndent(
      ++indentationLevel,
      '$backingPropertyName = ImageVector.Builder(',
    );
  indentationLevel++;
  imageVector.name?.let(
    (name) => sink.writelnIndent(indentationLevel, 'name = "$name",'),
  );
  sink
    ..writelnIndent(
      indentationLevel,
      'defaultWidth = ${numToKotlinFloatAsString(imageVector.width)}.dp,',
    )
    ..writelnIndent(
      indentationLevel,
      'defaultHeight = ${numToKotlinFloatAsString(imageVector.height)}.dp,',
    )
    ..writelnIndent(
      indentationLevel,
      'viewportWidth = '
      '${numToKotlinFloatAsString(imageVector.viewportWidth)},',
    )
    ..writelnIndent(
      indentationLevel,
      'viewportHeight = '
      '${numToKotlinFloatAsString(imageVector.viewportHeight)},',
    )
    ..writeArgumentIfNotNull(
      indentationLevel,
      'tintColor',
      imageVector.tintColor?.let(_colorToString),
    )
    ..writeArgumentIfNotNull(
      indentationLevel,
      'tintBlendMode',
      imageVector.tintBlendMode
          .takeIf((it) => it != ImageVector.defaultTintBlendMode),
    )
    ..writelnIndent(--indentationLevel, ')');
  indentationLevel = _writeNodes(
    sink,
    imageVector.nodes,
    ++indentationLevel,
    shouldStatementBePrecededByPoint: true,
  );
  sink
    ..writelnIndent(indentationLevel, '.build()')
    ..writelnIndent(indentationLevel -= 2, '}')
    ..writelnIndent(indentationLevel, 'return $backingPropertyName!!')
    ..writelnIndent(--indentationLevel, '}');
}

int _writeNodes(
  StringSink sink,
  Iterable<VectorNode> nodes,
  int indentationLevel, {
  bool shouldStatementBePrecededByPoint = false,
}) {
  nodes.forEachIndexed((index, node) {
    if (node is VectorGroup) {
      indentationLevel = writeGroup(
        sink,
        node,
        indentationLevel,
        shouldStatementBePrecededByPoint: shouldStatementBePrecededByPoint,
      );
    } else if (node is VectorPath) {
      indentationLevel = writePath(
        sink,
        node,
        indentationLevel,
        shouldStatementBePrecededByPoint: shouldStatementBePrecededByPoint,
      );
    }
  });
  return indentationLevel;
}

@visibleForTesting
int writeGroup(
  StringSink sink,
  VectorGroup group,
  int indentationLevel, {
  bool shouldStatementBePrecededByPoint = false,
}) {
  sink.writeIndent(
    indentationLevel,
    shouldStatementBePrecededByPoint ? '.group' : 'group',
  );
  // TODO: this should always return true based on the logic
  //       in `VectorGroupBuilder.build`; sort this out?
  if (group.id != null || group.definesTransformations) {
    sink.writeln('(');
    sink
      ..writeArgumentIfNotNull(++indentationLevel, 'name', group.id)
      ..writeArgumentIfNotNull(
          indentationLevel, 'rotate', group.rotation?.angle)
      ..writeArgumentIfNotNull(
        indentationLevel,
        'pivotX',
        group.rotation?.pivotX.takeIf((it) => it != VectorGroup.defaultPivotX),
      )
      ..writeArgumentIfNotNull(
        indentationLevel,
        'pivotY',
        group.rotation?.pivotY.takeIf((it) => it != VectorGroup.defaultPivotY),
      )
      ..writeArgumentIfNotNull(
        indentationLevel,
        'scaleX',
        group.scale?.x.takeIf((it) => it != VectorGroup.defaultScaleX),
      )
      ..writeArgumentIfNotNull(
        indentationLevel,
        'scaleY',
        group.scale?.y.takeIf((it) => it != VectorGroup.defaultScaleY),
      )
      ..writeArgumentIfNotNull(
        indentationLevel,
        'translationX',
        group.translation?.x
            .takeIf((it) => it != VectorGroup.defaultTranslationX),
      )
      ..writeArgumentIfNotNull(
        indentationLevel,
        'translationY',
        group.translation?.y
            .takeIf((it) => it != VectorGroup.defaultTranslationY),
      )
      ..writeArgumentIfNotNull(
          indentationLevel, 'clipPathData', group.clipPathData);
    sink.writeIndent(--indentationLevel, ')');
  }
  sink.writeln(' {');
  indentationLevel = _writeNodes(
    sink,
    group.nodes,
    ++indentationLevel,
    shouldStatementBePrecededByPoint: false,
  );
  sink.writelnIndent(--indentationLevel, '}');
  return indentationLevel;
}

@visibleForTesting
int writePath(
  StringSink sink,
  VectorPath path,
  int indentationLevel, {
  bool shouldStatementBePrecededByPoint = false,
}) {
  final isPathTrimmed = path.trimPathStart != null ||
      path.trimPathEnd != null ||
      path.trimPathOffset != null;
  sink.writeIndent(
    indentationLevel,
    (shouldStatementBePrecededByPoint ? '.' : '') +
        (isPathTrimmed ? 'addPath' : 'path'),
  );
  if (path.hasAttributes || isPathTrimmed) {
    sink.writeln('(');
    if (isPathTrimmed) {
      sink.writeArgumentIfNotNull(
        ++indentationLevel,
        'pathData',
        path.pathData,
      );
    }
    sink
      ..writeArgumentIfNotNull(
        isPathTrimmed ? indentationLevel : ++indentationLevel,
        'name',
        path.id,
      )
      ..writeArgumentIfNotNull(
        indentationLevel,
        'fill',
        path.fill.takeIf((it) => it != VectorPath.defaultFill),
      )
      ..writeArgumentIfNotNull(
        indentationLevel,
        'fillAlpha',
        path.fillAlpha.takeIf((it) => it != VectorPath.defaultFillAlpha),
      )
      ..writeArgumentIfNotNull(indentationLevel, 'stroke', path.stroke)
      ..writeArgumentIfNotNull(
        indentationLevel,
        'strokeAlpha',
        path.strokeAlpha.takeIf((it) => it != VectorPath.defaultStrokeAlpha),
      )
      ..writeArgumentIfNotNull(
        indentationLevel,
        'strokeLineWidth',
        path.strokeLineWidth
            .takeIf((it) => it != VectorPath.defaultStrokeLineWidth),
      )
      ..writeArgumentIfNotNull(
        indentationLevel,
        'strokeLineCap',
        path.strokeLineCap
            .takeIf((it) => it != VectorPath.defaultStrokeLineCap),
      )
      ..writeArgumentIfNotNull(
        indentationLevel,
        'strokeLineJoin',
        path.strokeLineJoin
            .takeIf((it) => it != VectorPath.defaultStrokeLineJoin),
      )
      ..writeArgumentIfNotNull(
        indentationLevel,
        'strokeLineMiter',
        path.strokeLineMiter
            .takeIf((it) => it != VectorPath.defaultStrokeLineMiter),
      )
      ..writeArgumentIfNotNull(
        indentationLevel,
        'pathFillType',
        path.pathFillType.takeIf((it) => it != VectorPath.defaultPathFillType),
      );
    if (isPathTrimmed) {
      sink
        ..writeArgumentIfNotNull(
          indentationLevel,
          'trimPathStart',
          path.trimPathStart
              .takeIf((it) => it != VectorPath.defaultTrimPathStart),
        )
        ..writeArgumentIfNotNull(
          indentationLevel,
          'trimPathEnd',
          path.trimPathEnd.takeIf((it) => it != VectorPath.defaultTrimPathEnd),
        )
        ..writeArgumentIfNotNull(
          indentationLevel,
          'trimPathOffset',
          path.trimPathOffset
              .takeIf((it) => it != VectorPath.defaultTrimPathOffset),
        );
    }
    if (!isPathTrimmed) {
      sink.writeIndent(--indentationLevel, ')');
    } else {
      sink.writelnIndent(--indentationLevel, ')');
    }
  }
  if (!isPathTrimmed) {
    sink.writeln(' {');
    _writePathNodes(sink, path.pathData, ++indentationLevel);
    sink.writelnIndent(--indentationLevel, '}');
  }
  return indentationLevel;
}

// asClassConstructorCall (as opposed to asBuilderFunctionCall):
// true  => `PathNode.MoveTo(x, y)`, when declaring VectorGroup clip path nodes
// false => `moveTo(x, y)`, when declaring VectorPath nodes
void _writePathNodes(
  StringSink sink,
  List<PathNode> nodes,
  int indentationLevel, {
  bool asClassConstructorCall = false,
}) {
  for (final node in nodes) {
    final commandName = node.command.name;
    final functionName = asClassConstructorCall
        ? 'PathNode.${commandName.capitalizeCharAt(0)}'
        : commandName;
    if (node.command == PathDataCommand.close && asClassConstructorCall) {
      sink.writeIndent(indentationLevel, '$functionName,');
    } else {
      sink
        ..writeIndent(indentationLevel, '$functionName(')
        ..writeAll(
          node.arguments.map(
            (argument) => argument is double
                ? numToKotlinFloatAsString(argument)
                : argument,
          ),
          ', ',
        )
        ..write(')');
      if (asClassConstructorCall) sink.write(',');
    }
    sink.writeln();
  }
}

String _colorToString(int color) =>
    'Color(0x${color.toRadixString(16).toUpperCase()})';

String _paintToBrushAsString(Brush paint, int indentationLevel) {
  final buffer = StringBuffer();
  if (paint is SolidColor) {
    buffer.write('SolidColor(${_colorToString(paint.colorInt)})');
  } else {
    paint as Gradient;
    final isGradientLinear = paint is LinearGradient;
    buffer
      ..write('Brush.')
      ..write(isGradientLinear ? 'linearGradient' : 'radialGradient')
      ..writeln('(');
    indentationLevel++;
    if (paint.stops.isEmpty) {
      buffer.writelnIndent(indentationLevel, 'listOf(');
      indentationLevel++;
      for (final color in paint.colors.map(_colorToString)) {
        buffer
          ..writeIndent(indentationLevel, color)
          ..writeln(',');
      }
      buffer.writelnIndent(--indentationLevel, '),');
    } else {
      for (var i = 0; i < paint.stops.length; i++) {
        buffer
          ..writeIndent(
            indentationLevel,
            numToKotlinFloatAsString(paint.stops[i]),
          )
          ..write(' to ')
          ..write(_colorToString(paint.colors[i]))
          ..writeln(',');
      }
    }
    if (isGradientLinear) {
      final startX = paint.startX;
      final startY = paint.startY;
      final endX = paint.endX;
      final endY = paint.endY;
      buffer
        ..writeArgumentIfNotNull(
          indentationLevel,
          'start',
          startX != 0.0 || startY != 0.0 ? Tuple2(startX, startY) : null,
        )
        ..writeArgumentIfNotNull(
          indentationLevel,
          'end',
          endX != double.infinity || endY != double.infinity
              ? Tuple2(endX, endY)
              : null,
        );
    } else {
      paint as RadialGradient;
      buffer
        ..writeArgumentIfNotNull(
          indentationLevel,
          'center',
          Tuple2(paint.centerX, paint.centerY),
        )
        ..writeArgumentIfNotNull(indentationLevel, 'radius', paint.radius);
    }
    buffer
      ..writeArgumentIfNotNull(indentationLevel, 'tileMode', paint.tileMode)
      ..writeIndent(--indentationLevel, ')');
  }
  return buffer.toString();
}

String _generateIndentation(int indentationLevel) =>
    String.fromCharCodes(List.filled(indentationLevel * 4, 0x20));

// @internal
String numToKotlinFloatAsString(num number) =>
    '${number.toStringWithMaxDecimals(4)}F';

extension _StringSinkWriting on StringSink {
  void writeIndent(int indentationLevel, Object obj) {
    write(_generateIndentation(indentationLevel) + obj.toString());
  }

  void writelnIndent(int indentationLevel, [Object obj = '']) {
    writeln(_generateIndentation(indentationLevel) + obj.toString());
  }

  void writeArgumentIfNotNull<T>(
    int indentationLevel,
    String parameterName,
    T? argument,
  ) {
    if (argument == null) return;
    writeIndent(indentationLevel, '$parameterName = ');
    final String argumentAsString;
    if (argument is double) {
      argumentAsString = numToKotlinFloatAsString(argument);
    } else if (argument is List<PathNode>) {
      final buffer = StringBuffer()..writeln('listOf(');
      _writePathNodes(
        buffer,
        argument,
        ++indentationLevel,
        asClassConstructorCall: true,
      );
      buffer.writeIndent(--indentationLevel, ')');
      argumentAsString = buffer.toString();
    } else if (argument is StrokeCap ||
        argument is StrokeJoin ||
        argument is PathFillType ||
        argument is TileMode ||
        argument is BlendMode) {
      final enumAsString = argument.toString();
      argumentAsString =
          enumAsString.capitalizeCharAt(enumAsString.indexOf('.') + 1);
    } else if (argument is Brush) {
      argumentAsString = _paintToBrushAsString(argument, indentationLevel);
    } else if (argument is Tuple2<double, double>) {
      final x = numToKotlinFloatAsString(argument.item1);
      final y = numToKotlinFloatAsString(argument.item2);
      argumentAsString = 'Offset($x, $y)';
    } else if (argument is String) {
      if (argument.startsWith('Color(')) {
        argumentAsString = argument;
      } else {
        argumentAsString = '"$argument"';
      }
    } else {
      argumentAsString = argument.toString();
    }
    writeln('$argumentAsString,');
  }
}
