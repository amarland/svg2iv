import '../model/vector_path.dart';

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
      PathNode(PathDataCommand.moveTo, [bounds.left, bounds.top]),
      PathNode(PathDataCommand.relativeHorizontalLineTo, [bounds.width]),
      PathNode(PathDataCommand.relativeVerticalLineTo, [bounds.height]),
      PathNode(PathDataCommand.relativeHorizontalLineTo, [-bounds.width]),
      PathNode(PathDataCommand.close, List.empty()),
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
      PathNode(
        PathDataCommand.moveTo,
        [bounds.left + topLeftX, bounds.top],
      ),
      PathNode(
        PathDataCommand.lineTo,
        [bounds.right - topRightX, bounds.top],
      ),
      PathNode(
        PathDataCommand.arcTo,
        [
          topRightX,
          topRightY,
          0.0,
          false,
          true,
          bounds.right,
          bounds.top + topRightY
        ],
      ),
      PathNode(
        PathDataCommand.lineTo,
        [bounds.right, bounds.bottom - bottomRightY],
      ),
      PathNode(
        PathDataCommand.arcTo,
        [
          bottomRightX,
          bottomRightY,
          0.0,
          false,
          true,
          bounds.right - bottomRightX,
          bounds.bottom
        ],
      ),
      PathNode(
        PathDataCommand.lineTo,
        [bounds.left + bottomLeftX, bounds.bottom],
      ),
      PathNode(
        PathDataCommand.arcTo,
        [
          bottomLeftX,
          bottomLeftY,
          0.0,
          false,
          true,
          bounds.left,
          bounds.bottom - bottomLeftY
        ],
      ),
      PathNode(
        PathDataCommand.lineTo,
        [bounds.left, bounds.top + topLeftY],
      ),
      PathNode(
        PathDataCommand.arcTo,
        [
          topLeftX,
          topLeftY,
          0.0,
          false,
          true,
          bounds.left + topLeftX,
          bounds.top
        ],
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
  final diameter = 2 * rx;
  return [
    PathNode(PathDataCommand.moveTo, [cx - rx, cy]),
    PathNode(
      PathDataCommand.relativeArcTo,
      [rx, ry, 0.0, true, isShapeACircle, diameter, 0.0],
    ),
    PathNode(
      PathDataCommand.relativeArcTo,
      [rx, ry, 0.0, true, isShapeACircle, -diameter, 0.0],
    ),
    if (isShapeACircle) PathNode(PathDataCommand.close, List.empty()),
  ];
}
