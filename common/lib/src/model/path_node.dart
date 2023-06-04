import 'package:svg2iv_common/extensions.dart';

sealed class PathNode {
  const PathNode();

  String get nodeClassName;

  String get builderMethodName => nodeClassName.toCamelCase();

  int get index;

  List<dynamic> get arguments;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          const ListEquality<dynamic>()
              .equals(arguments, (other as PathNode).arguments);

  @override
  int get hashCode =>
      index.hashCode ^ const ListEquality<dynamic>().hash(arguments);
}

class MoveToNode extends PathNode {
  const MoveToNode(this.x, this.y);

  final double x, y;

  @override
  String get nodeClassName => 'MoveTo';

  @override
  int get index => 0;

  @override
  List<dynamic> get arguments => [x, y];

  @override
  String toString() => 'M$x,$y';
}

class LineToNode extends PathNode {
  const LineToNode(this.x, this.y);

  final double x, y;

  @override
  String get nodeClassName => 'LineTo';

  @override
  int get index => 1;

  @override
  List<dynamic> get arguments => [x, y];

  @override
  String toString() => 'L$x,$y';
}

class CurveToNode extends PathNode {
  const CurveToNode(this.x1, this.y1, this.x2, this.y2, this.x3, this.y3);

  final double x1, y1, x2, y2, x3, y3;

  @override
  String get nodeClassName => 'CurveTo';

  @override
  int get index => 2;

  @override
  List<dynamic> get arguments => [x1, y1, x2, y2, x3, y3];

  @override
  String toString() => 'C$x1,$y1,$x2,$y2,$x3,$y3';
}

class ArcToNode extends PathNode {
  const ArcToNode({
    required this.rx,
    required this.ry,
    required this.angle,
    required this.largeArc,
    required this.sweep,
    required this.x,
    required this.y,
  });

  final double rx, ry, angle, x, y;
  final bool largeArc, sweep;

  @override
  String get nodeClassName => 'ArcTo';

  @override
  int get index => 3;

  @override
  List<dynamic> get arguments => [rx, ry, angle, largeArc, sweep, x, y];

  @override
  String toString() {
    return 'A$rx,$ry,$angle,${largeArc ? '1' : '0'},${sweep ? '1' : '0'},$x,$y';
  }
}

class CloseNode extends PathNode {
  const CloseNode();

  @override
  String get nodeClassName => 'Close';

  @override
  int get index => 4;

  @override
  List<dynamic> get arguments => List.empty();

  @override
  String toString() => 'Z';
}
