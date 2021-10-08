import 'dart:io';

import 'package:collection/collection.dart';
import 'package:svg2iv_common/extensions.dart';
import 'package:svg2iv_common/gradient.dart';
import 'package:svg2iv_common/image_vector.dart';
import 'package:svg2iv_common/vector_group.dart';
import 'package:svg2iv_common/vector_node.dart';
import 'package:svg2iv_common/vector_path.dart';
import 'package:tuple/tuple.dart';

const _commandsToFunctionAndClassNames = {
  PathDataCommand.close: Tuple2('close', 'Close'),
  PathDataCommand.moveTo: Tuple2('moveTo', 'MoveTo'),
  PathDataCommand.relativeMoveTo: Tuple2('moveToRelative', 'RelativeMoveTo'),
  PathDataCommand.lineTo: Tuple2('lineTo', 'LineTo'),
  PathDataCommand.relativeLineTo: Tuple2('lineToRelative', 'RelativeLineTo'),
  PathDataCommand.horizontalLineTo: Tuple2('horizontalLineTo', 'HorizontalTo'),
  PathDataCommand.relativeHorizontalLineTo:
      Tuple2('horizontalLineToRelative', 'RelativeHorizontalTo'),
  PathDataCommand.verticalLineTo: Tuple2('verticalLineTo', 'VerticalTo'),
  PathDataCommand.relativeVerticalLineTo:
      Tuple2('verticalLineToRelative', 'RelativeVerticalTo'),
  PathDataCommand.curveTo: Tuple2('curveTo', 'CurveTo'),
  PathDataCommand.relativeCurveTo: Tuple2('curveToRelative', 'RelativeCurveTo'),
  PathDataCommand.smoothCurveTo:
      Tuple2('reflectiveCurveTo', 'ReflectiveCurveTo'),
  PathDataCommand.relativeSmoothCurveTo:
      Tuple2('reflectiveCurveToRelative', 'RelativeReflectiveCurveTo'),
  PathDataCommand.quadraticBezierCurveTo: Tuple2('quadTo', 'QuadTo'),
  PathDataCommand.relativeQuadraticBezierCurveTo:
      Tuple2('quadToRelative', 'RelativeQuadTo'),
  PathDataCommand.smoothQuadraticBezierCurveTo:
      Tuple2('reflectiveQuadTo', 'ReflectiveQuadTo'),
  PathDataCommand.relativeSmoothQuadraticBezierCurveTo:
      Tuple2('reflectiveQuadToRelative', 'RelativeReflectiveQuadTo'),
  PathDataCommand.arcTo: Tuple2('arcTo', 'ArcTo'),
  PathDataCommand.relativeArcTo: Tuple2('arcToRelative', 'RelativeArcTo'),
};

Future<void> writeImageVectorsToFile(
  String destinationPath,
  Map<String, ImageVector> imageVectors, {
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
  Map<String, ImageVector> imageVectors, {
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
  sink
    ..writeln('import androidx.compose.ui.geometry.Offset')
    ..writeln('import androidx.compose.ui.graphics.*')
    ..writeln('import androidx.compose.ui.graphics.vector.*')
    ..writeln('import androidx.compose.ui.unit.dp')
    ..writeln();
  imageVectors.forEach(
    (sourceFileName, imageVector) => writeImageVector(
      sink,
      imageVector,
      sourceFileName.toPascalCase(),
      extensionReceiver,
    ),
  );
}

void writeImageVector(
  StringSink sink,
  ImageVector imageVector,
  String nameIfVectorNameNull, [
  String? extensionReceiver,
]) {
  var indentationLevel = 0;
  final extensionReceiverDeclaration =
      extensionReceiver.isNullOrEmpty ? '' : extensionReceiver! + '.';
  final imageVectorName = (imageVector.name ?? nameIfVectorNameNull);
  final backingPropertyName = '_' + imageVectorName.toCamelCase();
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
      'defaultWidth = ${_numToKotlinFloatAsString(imageVector.width)}.dp,',
    )
    ..writelnIndent(
      indentationLevel,
      'defaultHeight = ${_numToKotlinFloatAsString(imageVector.height)}.dp,',
    )
    ..writelnIndent(
      indentationLevel,
      'viewportWidth = '
      '${_numToKotlinFloatAsString(imageVector.viewportWidth)},',
    )
    ..writelnIndent(
      indentationLevel,
      'viewportHeight = '
      '${_numToKotlinFloatAsString(imageVector.viewportHeight)},',
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
    ..writelnIndent(--indentationLevel, '}')
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
  if (group.hasAttributes) {
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
          indentationLevel, 'translationX', group.translation?.x)
      ..writeArgumentIfNotNull(
          indentationLevel, 'translationY', group.translation?.y)
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
    _commandsToFunctionAndClassNames[node.command]?.let(
      (pair) {
        final name =
            asClassConstructorCall ? 'PathNode.${pair.item2}' : pair.item1;
        if (node.command == PathDataCommand.close && asClassConstructorCall) {
          sink.writeIndent(indentationLevel, '$name,');
        } else {
          sink
            ..writeIndent(indentationLevel, '$name(')
            ..writeAll(
              node.arguments.map(
                (argument) => argument is double
                    ? _numToKotlinFloatAsString(argument)
                    : argument,
              ),
              ', ',
            )
            ..write(')');
          if (asClassConstructorCall) sink.write(',');
        }
        sink.writeln();
      },
    );
  }
}

String _colorToString(int color) =>
    'Color(0x${color.toRadixString(16).toUpperCase()})';

String gradientToBrushAsString(Gradient gradient, int indentationLevel) {
  final buffer = StringBuffer();
  final colors = gradient.colors;
  if (colors.length == 1 || colors.every((c) => c == colors[0])) {
    buffer.write('SolidColor(${_colorToString(colors[0])})');
  } else {
    final isGradientLinear = gradient is LinearGradient;
    buffer
      ..write('Brush.')
      ..write(isGradientLinear ? 'linearGradient' : 'radialGradient')
      ..writeln('(');
    indentationLevel++;
    if (gradient.stops.isEmpty) {
      buffer.writelnIndent(indentationLevel, 'listOf(');
      indentationLevel++;
      for (final color in colors.map(_colorToString)) {
        buffer
          ..writeIndent(indentationLevel, color)
          ..writeln(',');
      }
      buffer.writelnIndent(--indentationLevel, '),');
    } else {
      for (var i = 0; i < gradient.stops.length; i++) {
        buffer
          ..writeIndent(
            indentationLevel,
            _numToKotlinFloatAsString(gradient.stops[i]),
          )
          ..write(' to ')
          ..write(_colorToString(colors[i]))
          ..writeln(',');
      }
    }
    if (isGradientLinear) {
      final linearGradient = gradient as LinearGradient;
      final startX = linearGradient.startX;
      final startY = linearGradient.startY;
      final endX = linearGradient.endX;
      final endY = linearGradient.endY;
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
      final radialGradient = gradient as RadialGradient;
      final centerX = radialGradient.centerX;
      final centerY = radialGradient.centerY;
      buffer
        ..writeArgumentIfNotNull(
          indentationLevel,
          'center',
          centerX != null || centerY != null
              ? Tuple2(centerX ?? 0.0, centerY ?? 0.0)
              : null,
        )
        ..writeArgumentIfNotNull(
            indentationLevel, 'radius', radialGradient.radius);
    }
    buffer
      ..writeArgumentIfNotNull(indentationLevel, 'tileMode', gradient.tileMode)
      ..writeIndent(--indentationLevel, ')');
  }
  return buffer.toString();
}

String _generateIndentation(int indentationLevel) =>
    String.fromCharCodes(List.filled(indentationLevel * 4, 0x20));

String _numToKotlinFloatAsString(num number) =>
    (number ~/ 1 == number
        ? number.toStringAsFixed(0)
        : number.toStringAsFixed(4).replaceFirst(RegExp(r'0*$'), '')) +
    'F';

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
      argumentAsString = _numToKotlinFloatAsString(argument);
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
      argumentAsString = argument
          .toString()
          .capitalizeCharAt(argument.toString().indexOf('.') + 1);
    } else if (argument is Gradient) {
      argumentAsString = gradientToBrushAsString(argument, indentationLevel);
    } else if (argument is Tuple2<double, double>) {
      final x = _numToKotlinFloatAsString(argument.item1);
      final y = _numToKotlinFloatAsString(argument.item2);
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
    writeln(argumentAsString + ',');
  }
}
