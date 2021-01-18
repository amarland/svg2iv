abstract class Transformation {}

class Rotation implements Transformation {
  const Rotation(this.angle, {double? pivotX, double? pivotY})
      : pivotX = pivotX ?? 0.0,
        pivotY = pivotY ?? 0.0;

  final double angle;
  final double? pivotX, pivotY;
}

class Scale implements Transformation {
  const Scale(this.x, [y]) : y = y ?? x;

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
  Rotation? _rotation;
  Scale? _scale;
  Translation? _translation;

  TransformationsBuilder rotation(Rotation rotation) {
    _rotation = rotation;
    return this;
  }

  TransformationsBuilder scale(Scale scale) {
    _scale = scale;
    return this;
  }

  TransformationsBuilder addTranslation(Translation translation) {
    _translation =
        _translation == null ? translation : _translation! + translation;
    return this;
  }

  Transformations? build() =>
      _rotation != null || _scale != null || _translation != null
          ? Transformations._init(_rotation, _scale, _translation)
          : null;
}
