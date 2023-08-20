import '../model/path_node.dart';

class Rect {
  Rect(this.left, this.top, this.right, this.bottom);

  Rect.fromRect(Rect other)
      : left = other.left,
        top = other.top,
        right = other.right,
        bottom = other.bottom;

  double left, top, right, bottom;

  double get width => right - left;

  double get height => bottom - top;

  void inset(double dx, double dy) {
    left += dx;
    top += dy;
    right -= dx;
    bottom -= dy;
  }
}

List<PathNode> obtainPathNodesForRectangle({
  required Rect bounds,
  // 8 values: X + Y for each corner, in clockwise order
  required List<double>? radii,
}) {
  if (radii == null || radii.isEmpty || radii.every((it) => it == 0.0)) {
    return [
      MoveToNode(bounds.left, bounds.top),
      LineToNode(bounds.right, bounds.top),
      LineToNode(bounds.right, bounds.bottom),
      LineToNode(bounds.left, bounds.bottom),
      const CloseNode(),
    ];
  } else {
    final halfWidth = bounds.width / 2;
    final halfHeight = bounds.height / 2;
    final topLeftX = radii[0] > halfWidth ? halfWidth : radii[0];
    final topLeftY = radii[1] > halfHeight ? halfHeight : radii[1];
    final topRightX = radii[2] > halfWidth ? halfWidth : radii[2];
    final topRightY = radii[3] > halfHeight ? halfHeight : radii[3];
    final bottomRightX = radii[4] > halfWidth ? halfWidth : radii[4];
    final bottomRightY = radii[5] > halfHeight ? halfHeight : radii[5];
    final bottomLeftX = radii[6] > halfWidth ? halfWidth : radii[6];
    final bottomLeftY = radii[7] > halfHeight ? halfHeight : radii[7];
    return [
      MoveToNode(bounds.left + topLeftX, bounds.top),
      LineToNode(bounds.right - topRightX, bounds.top),
      ArcToNode(
        rx: topRightX,
        ry: topRightY,
        angle: 0.0,
        largeArc: false,
        sweep: true,
        x: bounds.right,
        y: bounds.top + topRightY,
      ),
      LineToNode(bounds.right, bounds.bottom - bottomRightY),
      ArcToNode(
        rx: bottomRightX,
        ry: bottomRightY,
        angle: 0.0,
        largeArc: false,
        sweep: true,
        x: bounds.right - bottomRightX,
        y: bounds.bottom,
      ),
      LineToNode(bounds.left + bottomLeftX, bounds.bottom),
      ArcToNode(
        rx: bottomLeftX,
        ry: bottomLeftY,
        angle: 0.0,
        largeArc: false,
        sweep: true,
        x: bounds.left,
        y: bounds.bottom - bottomLeftY,
      ),
      LineToNode(bounds.left, bounds.top + topLeftY),
      ArcToNode(
        rx: topLeftX,
        ry: topLeftY,
        angle: 0.0,
        largeArc: false,
        sweep: true,
        x: bounds.left + topLeftX,
        y: bounds.top,
      ),
    ];
  }
}

List<PathNode> obtainPathNodesForEllipse({
  required double cx,
  required double cy,
  required double rx,
  required double ry,
}) {
  final isShapeACircle = rx == ry;
  final x = cx - rx;
  final diameter = 2 * rx;
  return [
    MoveToNode(x, cy),
    ArcToNode(
      rx: rx,
      ry: ry,
      angle: 0.0,
      largeArc: true,
      sweep: isShapeACircle,
      x: x + diameter,
      y: cy,
    ),
    ArcToNode(
      rx: rx,
      ry: ry,
      angle: 0.0,
      largeArc: true,
      sweep: isShapeACircle,
      x: x,
      y: cy,
    ),
    if (isShapeACircle) const CloseNode(),
  ];
}
