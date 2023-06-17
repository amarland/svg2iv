import 'package:equatable/equatable.dart';
import 'package:vector_math/vector_math.dart';

import 'vector_group.dart';

class Rotation extends Equatable {
  const Rotation(this.angle, {double? pivotX, double? pivotY})
      : pivotX = pivotX ?? 0.0,
        pivotY = pivotY ?? 0.0;

  final double angle;
  final double? pivotX, pivotY;

  @override
  List<Object?> get props => [angle, pivotX, pivotY];
}

class Scale extends Equatable {
  const Scale(this.x, [double? y]) : y = y ?? x;

  final double x;
  final double? y;

  @override
  List<Object?> get props => [x, y];
}

class Translation extends Equatable {
  const Translation(this.x, [double? y]) : y = y ?? 0.0;

  final double x;
  final double y;

  Translation operator +(Translation other) =>
      Translation(x + other.x, y + other.y);

  @override
  List<Object?> get props => [x, y];
}

class Transformations {
  Transformations._init(this.rotation, this.scale, this.translation);

  factory Transformations.fromMatrix4(Matrix4 matrix) {
    Quaternion rotationQuaternion = Quaternion.identity();
    Vector3 scaleVector = Vector3.zero();
    Vector3 translationVector = Vector3.zero();
    matrix.decompose(translationVector, rotationQuaternion, scaleVector);
    final rotationAxis = rotationQuaternion.axis;
    final rotation = _isQuaternionIdentity(rotationQuaternion)
        ? null
        : Rotation(
            degrees(rotationQuaternion.radians),
            pivotX: rotationAxis.x,
            pivotY: rotationAxis.y,
          );
    final scale = scaleVector.x == 1.0 && scaleVector.y == 1.0
        ? null
        : Scale(scaleVector.x, scaleVector.y);
    final translation = translationVector.x == 0.0 && translationVector.y == 0.0
        ? null
        : Translation(translationVector.x, translationVector.y);
    return Transformations._init(rotation, scale, translation);
  }

  final Rotation? rotation;
  final Scale? scale;
  Translation? translation;

  bool get definesTranslationOnly =>
      translation != null && rotation == null && scale == null;

  Translation? consumeTranslation() {
    final result = translation;
    translation = null;
    return result;
  }

  static bool _isQuaternionIdentity(Quaternion quaternion) =>
      quaternion.x == 0.0 &&
      quaternion.y == 0.0 &&
      quaternion.z == 0.0 &&
      quaternion.w == 1.0;
}

extension TranslationExtensions on Translation? {
  Translation orDefault() => this ?? Translation(0.0, 0.0);
}

class TransformationsBuilder {
  final _matrices = <Matrix4>[];

  TransformationsBuilder translate({double? x, double? y}) {
    x ??= VectorGroup.defaultTranslationX;
    y ??= VectorGroup.defaultTranslationY;
    if (x != VectorGroup.defaultTranslationX ||
        y != VectorGroup.defaultTranslationY) {
      _matrices.add(Matrix4.translationValues(x, y, 0.0));
    }
    return this;
  }

  TransformationsBuilder scale({required double x, double? y}) {
    if (x != VectorGroup.defaultScaleX) {
      _matrices.add(
        Matrix4.identity()..scale(x, y ?? x),
      );
    }
    return this;
  }

  TransformationsBuilder rotate(
    double degrees, {
    double? pivotX,
    double? pivotY,
  }) {
    if (degrees != 0.0) {
      final mustTranslate = pivotX != null || pivotY != null;
      pivotX ??= VectorGroup.defaultPivotX;
      pivotY ??= VectorGroup.defaultPivotY;
      if (mustTranslate) {
        translate(x: pivotX, y: pivotY);
      }
      _matrices.add(
        Matrix4.identity()..rotateZ(radians(degrees)),
      );
      if (mustTranslate) {
        translate(x: -pivotX, y: -pivotY);
      }
    }
    return this;
  }

  TransformationsBuilder skewX(double degrees) {
    if (degrees != 0.0) {
      _matrices.add(Matrix4.skewX(radians(degrees)));
    }
    return this;
  }

  TransformationsBuilder skewY(double degrees) {
    if (degrees != 0.0) {
      _matrices.add(Matrix4.skewY(radians(degrees)));
    }
    return this;
  }

  Transformations? build() {
    if (_matrices.isEmpty) {
      return null;
    }
    final result = _matrices[0];
    final count = _matrices.length;
    for (var index = 1; index < count; index++) {
      result.multiply(_matrices[index]);
    }
    return Transformations.fromMatrix4(result);
  }
}
