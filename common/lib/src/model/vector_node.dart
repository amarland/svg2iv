import 'package:meta/meta.dart';

abstract class VectorNode {
  const VectorNode(this.id);

  final String? id;
}

abstract class VectorNodeBuilder<T extends VectorNode,
    B extends VectorNodeBuilder<T, B>> {
  String? _id;

  @protected
  String? get id_ => _id;

  B id(String id) {
    _id = id;
    return this as B;
  }

  T build();
}

enum PathFillType { nonZero, evenOdd }

PathFillType? pathFillTypeFromString(String valueAsString) {
  switch (valueAsString.toLowerCase()) {
    case 'nonzero':
      return PathFillType.nonZero;
    case 'evenodd':
      return PathFillType.evenOdd;
  }
  return null;
}

enum StrokeCap { butt, round, square }

StrokeCap? strokeCapFromString(String valueAsString) {
  switch (valueAsString) {
    case 'butt':
      return StrokeCap.butt;
    case 'round':
      return StrokeCap.round;
    case 'square':
      return StrokeCap.square;
  }
  return null;
}

enum StrokeJoin { bevel, miter, round }

StrokeJoin? strokeJoinFromString(String valueAsString) {
  switch (valueAsString) {
    case 'bevel':
      return StrokeJoin.bevel;
    case 'miter':
      return StrokeJoin.miter;
    case 'round':
      return StrokeJoin.round;
  }
  return null;
}
