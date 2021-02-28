import 'package:svg2iv/extensions.dart';

abstract class Gradient {
  Gradient(this.colors, this.stops, this.tileMode) {
    if ((stops != null || !stops.isNullOrEmpty) &&
        colors.length != stops!.length) {
      throw StateError('If `stops` is provided,'
          ' it must be the same length as `colors`.');
    }
  }

  final List<int> colors;
  final List<double>? stops;
  final TileMode? tileMode;
}

class LinearGradient extends Gradient {
  LinearGradient(
    List<int> colors, {
    List<double>? stops,
    double? startX,
    double? startY,
    double? endX,
    double? endY,
    TileMode? tileMode,
  })  : startX = startX ?? 0.0,
        startY = startY ?? 0.0,
        endX = endX ?? double.infinity,
        endY = endY ?? double.infinity,
        super(colors, stops, tileMode);

  final double startX, startY, endX, endY;
}

class RadialGradient extends Gradient {
  RadialGradient(
    List<int> colors, {
    List<double>? stops,
    this.centerX,
    this.centerY,
    double? radius,
    TileMode? tileMode,
  })  : radius = radius ?? double.infinity,
        super(colors, stops, tileMode);

  final double? centerX, centerY;
  final double radius;
}

enum TileMode { clamp, repeated, mirror }
