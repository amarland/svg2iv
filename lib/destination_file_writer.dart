import 'dart:io';

import 'package:svg2va/extensions.dart';
import 'package:svg2va/model/gradient.dart';
import 'package:svg2va/model/image_vector.dart';
import 'package:svg2va/model/vector_group.dart';
import 'package:svg2va/model/vector_node.dart';
import 'package:svg2va/model/vector_path.dart';
import 'package:tuple/tuple.dart';

const _imports = [
  'androidx.compose.ui.graphics.*',
  'androidx.compose.ui.unit.dp',
];

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

void writeImageVectorsToFile(
  String destinationPath,
  Map<String, ImageVector> imageVectors, [
  String? extensionReceiver,
]) async {
  if (!destinationPath.endsWith('.kt')) {
    destinationPath += '.kt';
  }
  final file = File(destinationPath).absolute;
  final fileSink = file.openWrite();
  final pathSeparator = Platform.pathSeparator;
  final sourceDirectoryPattern =
      'src\\$pathSeparator(java|kotlin)\\$pathSeparator';
  final absoluteFilePath = file.path;
  final String packageName;
  final startOfPackageName =
      RegExp(sourceDirectoryPattern).firstMatch(absoluteFilePath)?.end;
  if (startOfPackageName == null) {
    packageName = '<package>';
  } else {
    final endOfPackageName = absoluteFilePath.lastIndexOfOrNull('.') ??
        absoluteFilePath.lastIndexOfOrNull(pathSeparator) ??
        absoluteFilePath.length;
    packageName =
        absoluteFilePath.substring(startOfPackageName, endOfPackageName);
  }
  fileSink
    ..writeln('package $packageName')
    ..writeln()
    ..writeAll(_imports)
    ..writeln()
    ..writeln();
  imageVectors.forEach(
    (sourceFileName, imageVector) => writeImageVector(
      fileSink,
      imageVector,
      sourceFileName.toPascalCase(),
      extensionReceiver,
    ),
  );
  await fileSink.flush();
  await fileSink.close();
}

void writeImageVector(
  StringSink sink,
  ImageVector imageVector,
  String nameIfVectorNameNull, [
  String? extensionReceiver,
]) {
  var indentationLevel = 0;
  final extensionReceiverDeclaration =
      extensionReceiver?.let((s) => s.capitalizeCharAt(0) + '.') ?? '';
  final imageVectorName = (imageVector.name ?? nameIfVectorNameNull);
  sink
    ..writeln(
      'private var _${imageVectorName.toCamelCase()}: ImageVector? = null',
    )
    ..writeln()
    ..writeln(
      'val $extensionReceiverDeclaration$imageVectorName: ImageVector',
    )
    ..writelnIndent(++indentationLevel, 'get() = _$imageVectorName ?: run {')
    ..writelnIndent(++indentationLevel, 'ImageVector.Builder(');
  indentationLevel++;
  imageVector.name?.let(
    (name) => sink.writelnIndent(
      indentationLevel,
      'name = "${name.toPascalCase()}",',
    ),
  );
  sink
    ..writelnIndent(indentationLevel, 'defaultWidth = ${imageVector.width}.dp,')
    ..writelnIndent(
        indentationLevel, 'defaultHeight = ${imageVector.height}.dp,')
    ..writelnIndent(
      indentationLevel,
      'viewportWidth = ' + _numToKotlinFloatAsString(imageVector.viewportWidth),
    )
    ..writelnIndent(
      indentationLevel,
      'viewportHeight = ' +
          _numToKotlinFloatAsString(imageVector.viewportHeight),
    )
    ..writelnIndent(--indentationLevel, ')')
    ..writeIndent(++indentationLevel, '.');
  indentationLevel = writeGroup(sink, imageVector.group, indentationLevel);
  sink
    ..writeln('.build()')
    ..writelnIndent(--indentationLevel, '}');
}

int writeGroup(StringSink sink, VectorGroup group, int indentationLevel) {
  sink.writeIndent(indentationLevel, 'group');
  if (group.hasAttributes) {
    sink.writeln('(');
    sink
      ..writeArgumentIfNotNull(++indentationLevel, 'name', group.id)
      ..writeArgumentIfNotNull(
          indentationLevel, 'rotation', group.rotation?.angle)
      ..writeArgumentIfNotNull(
          indentationLevel, 'pivotX', group.rotation?.pivotX)
      ..writeArgumentIfNotNull(
          indentationLevel, 'pivotY', group.rotation?.pivotY)
      ..writeArgumentIfNotNull(indentationLevel, 'scaleX', group.scale?.x)
      ..writeArgumentIfNotNull(indentationLevel, 'scaleY', group.scale?.y)
      ..writeArgumentIfNotNull(
          indentationLevel, 'translationX', group.translation?.x)
      ..writeArgumentIfNotNull(
          indentationLevel, 'translationY', group.translation?.y)
      ..writeArgumentIfNotNull(
          indentationLevel, 'clipPathData', group.clipPathData);
    sink.writeIndent(--indentationLevel, ')');
  }
  sink.writeln(' {');
  indentationLevel++;
  for (final node in group.nodes) {
    if (node is VectorGroup) {
      indentationLevel = writeGroup(sink, node, indentationLevel);
    } else if (node is VectorPath) {
      indentationLevel = writePath(sink, node, indentationLevel);
    }
  }
  sink.writelnIndent(--indentationLevel, '}');
  return indentationLevel;
}

int writePath(StringSink sink, VectorPath path, int indentationLevel) {
  sink.writeIndent(indentationLevel, 'path');
  if (path.hasAttributes) {
    sink.writeln('(');
    sink
      ..writeArgumentIfNotNull(++indentationLevel, 'name', path.id)
      ..writeArgumentIfNotNull(indentationLevel, 'fill', path.fill)
      ..writeArgumentIfNotNull(indentationLevel, 'fillAlpha', path.fillAlpha)
      ..writeArgumentIfNotNull(indentationLevel, 'stroke', path.stroke)
      ..writeArgumentIfNotNull(
          indentationLevel, 'strokeAlpha', path.strokeAlpha)
      ..writeArgumentIfNotNull(
          indentationLevel, 'strokeLineWidth', path.strokeLineWidth)
      ..writeArgumentIfNotNull(
          indentationLevel, 'strokeLineCap', path.strokeLineCap)
      ..writeArgumentIfNotNull(
          indentationLevel, 'strokeLineJoin', path.strokeLineJoin)
      ..writeArgumentIfNotNull(
          indentationLevel, 'strokeLineMiter', path.strokeLineMiter)
      ..writeArgumentIfNotNull(
          indentationLevel, 'pathFillType', path.pathFillType);
    sink.writeIndent(--indentationLevel, ')');
  }
  sink.writeln(' {');
  _writePathNodes(sink, path.pathData, ++indentationLevel);
  sink.writelnIndent(--indentationLevel, '}');
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
        sink.writeln();
      },
    );
  }
}

String gradientToBrushAsString(Gradient gradient, int indentationLevel) {
  final buffer = StringBuffer();
  if (gradient.colors.length == 1) {
    buffer.write('SolidColor(Color(${gradient.colors[0]}))');
  } else {
    final isGradientLinear = gradient is LinearGradient;
    buffer
      ..write('Brush.')
      ..write(isGradientLinear ? 'linearGradient' : 'radialGradient')
      ..writeln('(');
    indentationLevel++;
    if (gradient.stops == null) {
      buffer
        ..write(_generateIndentation(indentationLevel))
        ..write('listOf(')
        ..writeAll(gradient.colors.map((c) => 'Color($c)'), ', ')
        ..writeln('),');
    } else {
      final lastIndex = gradient.stops!.length - 1;
      for (var i = 0; i <= lastIndex; i++) {
        buffer
          ..write(_generateIndentation(indentationLevel))
          ..write(_numToKotlinFloatAsString(gradient.stops![i]))
          ..write(' to ')
          ..write('Color(${gradient.colors[i]})')
          ..writeln(',');
      }
    }
    if (isGradientLinear) {
      final linearGradient = gradient as LinearGradient;
      buffer
        ..writeArgumentIfNotNull(
            indentationLevel, 'startX', linearGradient.startX)
        ..writeArgumentIfNotNull(
            indentationLevel, 'startY', linearGradient.startY)
        ..writeArgumentIfNotNull(indentationLevel, 'endX', linearGradient.endX)
        ..writeArgumentIfNotNull(indentationLevel, 'endY', linearGradient.endY);
    } else {
      final radialGradient = gradient as RadialGradient;
      buffer
        ..writeArgumentIfNotNull(
            indentationLevel, 'centerX', radialGradient.centerX)
        ..writeArgumentIfNotNull(
            indentationLevel, 'centerY', radialGradient.centerY)
        ..writeArgumentIfNotNull(
            indentationLevel, 'radius', radialGradient.radius);
    }
    buffer
      ..writeArgumentIfNotNull(indentationLevel, 'tileMode', gradient.tileMode)
      ..write(_generateIndentation(--indentationLevel))
      ..write(')');
  }
  return buffer.toString();
}

String _generateIndentation(int indentationLevel) =>
    String.fromCharCodes(List.filled(indentationLevel * 4, 0x20));

String _numToKotlinFloatAsString(num number) =>
    '${number ~/ 1 == number ? number.toStringAsFixed(0) : number.toString()}F';

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
        argument is TileMode) {
      argumentAsString = argument
          .toString()
          .capitalizeCharAt(argument.toString().indexOf('.') + 1);
    } else if (argument is Gradient) {
      argumentAsString = gradientToBrushAsString(argument, indentationLevel);
    } else if (argument is String) {
      argumentAsString = '"$argument"';
    } else {
      argumentAsString = argument.toString();
    }
    writeln(argumentAsString + ',');
  }
}
