import 'dart:io';

import 'package:svg2va/extensions.dart';
import 'package:svg2va/model/gradient.dart';
import 'package:svg2va/model/image_vector.dart';
import 'package:svg2va/model/vector_group.dart';
import 'package:svg2va/model/vector_node.dart';
import 'package:svg2va/model/vector_path.dart';

const _imports = [
  'androidx.compose.ui.graphics.Color',
  'androidx.compose.ui.graphics.LinearGradient',
  'androidx.compose.ui.graphics.PathFillType',
  'androidx.compose.ui.graphics.RadialGradient',
  'androidx.compose.ui.graphics.SolidColor',
  'androidx.compose.ui.graphics.StrokeCap',
  'androidx.compose.ui.graphics.StrokeJoin',
  'androidx.compose.ui.graphics.TileMode',
  'androidx.compose.ui.graphics.vector.VectorAsset',
  'androidx.compose.ui.graphics.vector.VectorAssetBuilder',
  'androidx.compose.ui.graphics.vector.path',
  'androidx.compose.ui.unit.dp',
];

const _commandsToFunctionNames = {
  PathDataCommand.close: 'close',
  PathDataCommand.moveTo: 'moveTo',
  PathDataCommand.relativeMoveTo: 'moveToRelative',
  PathDataCommand.lineTo: 'lineTo',
  PathDataCommand.relativeLineTo: 'lineToRelative',
  PathDataCommand.horizontalLineTo: 'horizontalLineTo',
  PathDataCommand.relativeHorizontalLineTo: 'horizontalLineToRelative',
  PathDataCommand.verticalLineTo: 'verticalLineTo',
  PathDataCommand.relativeVerticalLineTo: 'verticalLineToRelative',
  PathDataCommand.curveTo: 'curveTo',
  PathDataCommand.relativeCurveTo: 'curveToRelative',
  PathDataCommand.smoothCurveTo: 'reflectiveCurveTo',
  PathDataCommand.relativeSmoothCurveTo: 'reflectiveCurveToRelative',
  PathDataCommand.quadraticBezierCurveTo: 'quadTo',
  PathDataCommand.relativeQuadraticBezierCurveTo: 'quadToRelative',
  PathDataCommand.smoothQuadraticBezierCurveTo: 'reflectiveQuadTo',
  PathDataCommand.relativeSmoothQuadraticBezierCurveTo:
      'reflectiveQuadToRelative',
  PathDataCommand.arcTo: 'arcTo',
  PathDataCommand.relativeArcTo: 'arcToRelative',
};

void writeToFile(
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
      sourceFileName,
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
  final imageVectorName =
      (imageVector.name ?? nameIfVectorNameNull).toCamelCase();
  sink
    ..writeln('private var _$imageVectorName: VectorAsset? = null')
    ..writeln()
    ..writeln('val ${extensionReceiverDeclaration}'
        '${imageVectorName.capitalizeCharAt(0)}: VectorAsset')
    ..writelnIndent(++indentationLevel, 'get() = _$imageVectorName ?: run {')
    ..writelnIndent(++indentationLevel, 'VectorAssetBuilder(');
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
  if (group.id != null || group.hasTransformations) {
    sink.writeln('(');
    sink
      ..writeArgumentIfNotNull<String>(
        ++indentationLevel,
        'name',
        group.id,
        (name) => '"${name.toPascalCase()}"',
      )
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
          indentationLevel, 'translationY', group.translation?.y);
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
      ..writeArgumentIfNotNull<String>(
        ++indentationLevel,
        'name',
        path.id,
        (name) => '"${name.toPascalCase()}"',
      )
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
  indentationLevel++;
  for (final instruction in path.pathData) {
    _commandsToFunctionNames[instruction.command]?.let(
      (name) => sink
        ..writeIndent(indentationLevel, '$name(')
        ..writeAll(
          instruction.arguments.map(
            (argument) => argument is double
                ? _numToKotlinFloatAsString(argument)
                : argument,
          ),
          ', ',
        )
        ..writeln(')'),
    );
  }
  sink.writelnIndent(--indentationLevel, '}');
  return indentationLevel;
}

String gradientToBrushAsString(Gradient gradient, int indentationLevel) {
  final buffer = StringBuffer();
  if (gradient.colors.length == 1) {
    buffer.write('SolidColor(Color(${gradient.colors[0]}))');
  } else {
    final isGradientLinear = gradient is LinearGradient;
    buffer
      ..write(isGradientLinear ? 'LinearGradient' : 'RadialGradient')
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
    T? argument, [
    String Function(T)? toString,
  ]) {
    if (argument == null) return;
    writeIndent(indentationLevel, '$parameterName = ');
    final String argumentAsString;
    if (toString != null) {
      argumentAsString = toString(argument);
    } else {
      if (argument is double) {
        argumentAsString = _numToKotlinFloatAsString(argument);
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
    }
    writeln(argumentAsString + ',');
  }
}
