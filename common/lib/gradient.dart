import 'package:meta/meta.dart';

abstract class Gradient {
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

  @factory
  static Gradient fromArgb(int color) => LinearGradient([color]);

  @factory
  static Gradient fromArgbComponents(int alpha, int red, int green, int blue) =>
      LinearGradient([(alpha << 24) | (red << 16) | (green << 8) | blue]);

  @factory
  static Gradient? fromHexString(String hexString) {
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
    return LinearGradient([temp]);
  }

  final List<int> colors;
  final List<double> stops;
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
    double? centerX,
    double? centerY,
    double? radius,
    TileMode? tileMode,
  })  : radius = radius ?? double.infinity,
        centerX = centerX ?? 0.0,
        centerY = centerY ?? 0.0,
        super(colors, stops, tileMode);

  final double centerX, centerY;
  final double radius;
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
}
