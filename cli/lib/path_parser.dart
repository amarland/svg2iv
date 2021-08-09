/*
import 'dart:typed_data';
import 'dart:ui';

import 'package:svg2iv/vector_path.dart';
import 'package:svg_path_parser/svg_path_parser.dart';

class PathParser implements Parser {
  PathParser(source) : _innerParser = Parser(source) {
    _innerParser.path = _PathProxy();
  }

  final Parser _innerParser;

  @override
  PathProxy get path => _innerParser.path as PathProxy;

  @override
  set path(Path path) => throw UnimplementedError();

  @override
  PathProxy? parse() {
    try {
      return _innerParser.parse() as PathProxy;
    } catch (_) {
      return null;
    }
  }
}

abstract class PathProxy implements Path {
  List<PathDataInstruction> get pathNodes;
}

class _PathProxy implements PathProxy {
  final List<PathDataInstruction> _pathNodes = [];

  @override
  List<PathDataInstruction> get pathNodes =>
      _pathNodes.toList(growable: false);

  @override
  PathFillType get fillType => throw UnimplementedError();

  @override
  set fillType(PathFillType pathFillType) => throw UnimplementedError();

  @override
  void addArc(Rect oval, double startAngle, double sweepAngle) =>
      throw UnimplementedError();

  @override
  void addOval(Rect oval) => throw UnimplementedError();

  @override
  void addPath(Path path, Offset offset, {Float64List? matrix4}) =>
      throw UnimplementedError();

  @override
  void addPolygon(List<Offset> points, bool close) =>
      throw UnimplementedError();

  @override
  void addRRect(RRect r) => throw UnimplementedError();

  @override
  void addRect(Rect r) => throw UnimplementedError();

  @override
  void arcTo(Rect r, double startAngle, double sweepAngle, bool forceMoveTo) =>
      throw UnimplementedError();

  @override
  void arcToPoint(
    Offset arcEnd, {
    Radius radius = Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) {
    // hRadius, vRadius, theta, isMoreThanHalf, isPositiveArc, x, y
    _pathNodes.add(
      PathDataInstruction(
        PathDataCommand.arcTo,
        [
          radius.x,
          radius.y,
          rotation,
          largeArc,
          clockwise,
          arcEnd.dx,
          arcEnd.dy,
        ],
      ),
    );
  }

  @override
  void close() {
    _pathNodes.add(PathDataInstruction(PathDataCommand.close, List.empty()));
  }

  @override
  PathMetrics computeMetrics({bool forceClosed = false}) =>
      throw UnimplementedError();

  @override
  void conicTo(double x1, double y1, double x2, double y2, double w) =>
      throw UnimplementedError();

  @override
  bool contains(Offset point) => throw UnimplementedError();

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    _pathNodes.add(
      PathDataInstruction(
        PathDataCommand.curveTo,
        [x1, y1, x2, y2, x3, y3],
      ),
    );
  }

  @override
  void extendWithPath(Path path, Offset offset, {Float64List? matrix4}) =>
      throw UnimplementedError();

  @override
  Rect getBounds() => throw UnimplementedError();

  @override
  void lineTo(double x, double y) {
    _pathNodes.add(PathDataInstruction(PathDataCommand.lineTo, [x, y]));
  }

  @override
  void moveTo(double x, double y) {
    _pathNodes.add(PathDataInstruction(PathDataCommand.moveTo, [x, y]));
  }

  @override
  void quadraticBezierTo(double x1, double y1, double x2, double y2) {
    _pathNodes.add(
      PathDataInstruction(
        PathDataCommand.quadraticBezierCurveTo,
        [x1, y1, x1, y2],
      ),
    );
  }

  @override
  void relativeArcToPoint(
    Offset arcEndDelta, {
    Radius radius = Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) {
    // hRadius, vRadius, theta, isMoreThanHalf, isPositiveArc, x, y
    _pathNodes.add(
      PathDataInstruction(
        PathDataCommand.relativeArcTo,
        [
          radius.x,
          radius.y,
          rotation,
          largeArc,
          clockwise,
          arcEndDelta.dx,
          arcEndDelta.dy,
        ],
      ),
    );
  }

  @override
  void relativeConicTo(double x1, double y1, double x2, double y2, double w) =>
      throw UnimplementedError();

  @override
  void relativeCubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    _pathNodes.add(
      PathDataInstruction(
        PathDataCommand.relativeCurveTo,
        [x1, y1, x2, y2, x3, y3],
      ),
    );
  }

  @override
  void relativeLineTo(double dx, double dy) {
    _pathNodes.add(
      PathDataInstruction(
        PathDataCommand.relativeLineTo,
        [dx, dy],
      ),
    );
  }

  @override
  void relativeMoveTo(double dx, double dy) {
    _pathNodes.add(
      PathDataInstruction(
        PathDataCommand.relativeMoveTo,
        [dx, dy],
      ),
    );
  }

  @override
  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2) {
    _pathNodes.add(
      PathDataInstruction(
        PathDataCommand.relativeQuadraticBezierCurveTo,
        [x1, y1, x2, y2],
      ),
    );
  }

  @override
  void reset() {
    _pathNodes.clear();
  }

  @override
  Path shift(Offset offset) => throw UnimplementedError();

  @override
  Path transform(Float64List matrix4) => throw UnimplementedError();
}
*/
