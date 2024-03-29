import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class Brush extends Equatable {
  const Brush();
}

class SolidColor extends Brush {
  const SolidColor(this.colorInt);

  final int colorInt;

  @factory
  static SolidColor fromArgbComponents(int a, int r, int g, int b) =>
      SolidColor((a << 24) | (r << 16) | (g << 8) | b);

  @factory
  static SolidColor? fromHexString(String hexString) {
    const alphaMask = 0xFF000000;
    final colorAsString = hexString.substring(1);
    final color = int.tryParse(colorAsString, radix: 16);
    if (color == null) return null;
    int temp;
    switch (colorAsString.length) {
      case 8:
        // #AARRGGBB
        temp = color;
        break;
      case 6:
        // #RRGGBB
        temp = color | alphaMask;
        break;
      case 4:
        // #ARGB
        temp = (color >> 12 & 0xF) * 0x11000000;
        continue rgb;
      rgb:
      case 3:
        // #RGB
        temp = (color >> 8 & 0xF) * 0x110000;
        temp = temp | (color >> 4 & 0xF) * 0x1100;
        temp = temp | (color & 0xF) * 0x11;
        temp = temp | alphaMask;
        break;
      default:
        return null;
    }
    return SolidColor(temp);
  }

  @override
  List<Object?> get props => [colorInt];
}

abstract class Gradient extends Brush {
  Gradient(
    this.colors,
    List<double>? stops,
    this.tileMode,
  ) : stops = stops ?? List.empty() {
    if (this.stops.isNotEmpty && colors.length != this.stops.length) {
      throw StateError('If `stops` is provided,'
          ' it must be the same length as `colors`.');
    }
  }

  final List<int> colors;
  final List<double> stops;
  final TileMode? tileMode;

  @override
  List<Object?> get props => [colors, stops, tileMode];
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
  })  : startX = startX ?? defaultStartX,
        startY = startY ?? defaultStartY,
        endX = endX ?? defaultEndX,
        endY = endY ?? defaultEndY,
        super(colors, stops, tileMode);

  static final defaultStartX = 0.0;
  static final defaultStartY = 0.0;
  static final defaultEndX = double.infinity;
  static final defaultEndY = 0.0;

  final double startX, startY, endX, endY;

  @override
  List<Object?> get props => super.props..addAll([startX, startY, endX, endY]);
}

class RadialGradient extends Gradient {
  RadialGradient(
    List<int> colors, {
    List<double>? stops,
    double? centerX,
    double? centerY,
    double? radius,
    TileMode? tileMode,
  })  : radius = radius ?? defaultRadius,
        centerX = centerX ?? defaultCenterX,
        centerY = centerY ?? defaultCenterY,
        super(colors, stops, tileMode);

  static final defaultCenterX = 0.0;
  static final defaultCenterY = 0.0;
  static final defaultRadius = double.infinity;

  final double centerX, centerY;
  final double radius;

  @override
  List<Object?> get props => super.props..addAll([centerX, centerY, radius]);
}

enum TileMode { clamp, repeated, mirror }

TileMode? tileModeFromString(String valueAsString) {
  switch (valueAsString) {
    case 'pad':
      return TileMode.clamp;
    case 'repeat':
      return TileMode.repeated;
    case 'reflect':
      return TileMode.mirror;
  }
  return null;
}
