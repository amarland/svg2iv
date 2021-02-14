import 'package:svg2va/extensions.dart';

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
    this.startX = 0.0,
    this.startY = 0.0,
    this.endX = double.infinity,
    this.endY = double.infinity,
    TileMode? tileMode,
  }) : super(colors, stops, tileMode);

  final double startX, startY, endX, endY;
}

class RadialGradient extends Gradient {
  RadialGradient(
    List<int> colors, {
    List<double>? stops,
    this.centerX,
    this.centerY,
    this.radius = double.infinity,
    TileMode? tileMode,
  }) : super(colors, stops, tileMode);

  final double? centerX, centerY;
  final double radius;
}

enum TileMode { clamp, repeated, mirror }
