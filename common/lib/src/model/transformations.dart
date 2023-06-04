import 'vector_group.dart';

class Rotation {
  const Rotation._(this.angle, this.pivotX, this.pivotY);

  final double angle;
  final double? pivotX, pivotY;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Rotation &&
          runtimeType == other.runtimeType &&
          angle == other.angle &&
          pivotX == other.pivotX &&
          pivotY == other.pivotY;

  @override
  int get hashCode => angle.hashCode ^ pivotX.hashCode ^ pivotY.hashCode;
}

class Scale {
  const Scale._(this.x, this.y);

  final double x;
  final double? y;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Scale &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

class Translation {
  const Translation._(this.x, this.y);

  final double x, y;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Translation &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

class Transformations {
  const Transformations._(this.rotation, this.scale, this.translation);

  final Rotation? rotation;
  final Scale? scale;
  final Translation? translation;
}

class TransformationsBuilder {
  Rotation? _rotation;
  Scale? _scale;
  Translation? _translation;

  TransformationsBuilder translate({double? x, double? y}) {
    x ??= VectorGroup.defaultTranslationX;
    y ??= VectorGroup.defaultTranslationY;
    if (x != VectorGroup.defaultTranslationX ||
        y != VectorGroup.defaultTranslationY) {
      _translation = Translation._(x, y);
    }
    return this;
  }

  TransformationsBuilder scale({required double x, double? y}) {
    y ??= x;
    if (x != VectorGroup.defaultScaleX || y != VectorGroup.defaultScaleY) {
      _scale = Scale._(x, y);
    }
    return this;
  }

  TransformationsBuilder rotate(
    double degrees, {
    double? pivotX,
    double? pivotY,
  }) {
    if (degrees != 0.0) {
      pivotX ??= VectorGroup.defaultPivotX;
      pivotY ??= VectorGroup.defaultPivotY;
      _rotation = Rotation._(degrees, pivotX, pivotY);
    }
    return this;
  }

  Transformations? build() {
    if (_rotation == null && _scale == null && _translation == null) {
      return null;
    }
    return Transformations._(_rotation, _scale, _translation);
  }
}
