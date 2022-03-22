import 'package:vector_math/vector_math.dart'
    show degrees, radians, Vector3, Quaternion, Matrix4;

abstract class Transformation {}

class Rotation implements Transformation {
  const Rotation(this.angle, {double? pivotX, double? pivotY})
      : pivotX = pivotX ?? 0.0,
        pivotY = pivotY ?? 0.0;

  final double angle;
  final double? pivotX, pivotY;
}

class Scale implements Transformation {
  const Scale(this.x, [double? y]) : y = y ?? x;

  final double x;
  final double? y;
}

class Translation implements Transformation {
  const Translation(this.x, [double? y]) : y = y ?? 0.0;

  final double x;
  final double y;

  Translation operator +(Translation other) =>
      Translation(x + other.x, y + other.y);
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
}

extension TranslationExtensions on Translation? {
  Translation orDefault() => this ?? Translation(0.0, 0.0);
}

class TransformationsBuilder {
  Matrix4 _matrix = Matrix4.identity();

  TransformationsBuilder rotate({
    required double angleInDegrees,
    double? pivotX,
    double? pivotY,
  }) {
    final angleInRadians = radians(angleInDegrees);
    if (pivotX != null || pivotY != null) {
      pivotX ??= 0.0;
      pivotY ??= 0.0;
      _matrix
        ..translate(pivotX, pivotY)
        ..multiply(Matrix4.rotationZ(angleInRadians))
        ..translate(-pivotX, -pivotY);
    } else {
      _matrix.rotateZ(angleInRadians);
    }
    return this;
  }

  TransformationsBuilder scale({required double x, double? y}) {
    _matrix.scale(x, y ?? x);
    return this;
  }

  TransformationsBuilder translate({required double x, double? y}) {
    _matrix.translate(x, y ?? 0.0);
    return this;
  }

  TransformationsBuilder skewX(double x) {
    _matrix = Matrix4.skewX(x).multiplied(_matrix);
    return this;
  }

  TransformationsBuilder skewY(double y) {
    _matrix = Matrix4.skewY(y).multiplied(_matrix);
    return this;
  }

  Transformations? build() =>
      _matrix.isIdentity() ? null : Transformations.fromMatrix4(_matrix);
}

bool _isQuaternionIdentity(Quaternion quaternion) =>
    quaternion.x == 0.0 &&
    quaternion.y == 0.0 &&
    quaternion.z == 0.0 &&
    quaternion.w == 1.0;
