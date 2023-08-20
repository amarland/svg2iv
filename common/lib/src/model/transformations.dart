import 'package:equatable/equatable.dart';

import 'vector_group.dart';

class Rotation extends Equatable {
  const Rotation._(this.angle, this.pivotX, this.pivotY);

  final double angle;
  final double? pivotX, pivotY;

  @override
  List<Object?> get props => [angle, pivotX, pivotY];
}

class Scale extends Equatable {
  const Scale._(this.x, this.y);

  final double x;
  final double? y;

  @override
  List<Object?> get props => [x, y];
}

class Translation extends Equatable {
  const Translation._(this.x, this.y);

  final double x, y;

  @override
  List<Object?> get props => [x, y];
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
