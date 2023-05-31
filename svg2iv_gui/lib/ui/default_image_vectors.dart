import 'package:svg2iv_common/models.dart';

class CustomIcons {
  CustomIcons._();

  static final home = ImageVectorBuilder(96.0, 96.0)
      .addNode(
        VectorPathBuilder(
          [
            const PathNode(PathDataCommand.moveTo, [22.0, 78.0]),
            const PathNode(PathDataCommand.lineTo, [37.0, 78.0]),
            const PathNode(PathDataCommand.lineTo, [37.0, 53.0]),
            const PathNode(PathDataCommand.lineTo, [59.0, 53.0]),
            const PathNode(PathDataCommand.lineTo, [59.0, 78.0]),
            const PathNode(PathDataCommand.lineTo, [74.0, 78.0]),
            const PathNode(PathDataCommand.lineTo, [74.0, 39.0]),
            const PathNode(PathDataCommand.lineTo, [48.0, 19.5]),
            const PathNode(PathDataCommand.lineTo, [22.0, 39.0]),
            const PathNode(PathDataCommand.lineTo, [22.0, 78.0]),
            const PathNode(PathDataCommand.moveTo, [16.0, 84.0]),
            const PathNode(PathDataCommand.lineTo, [16.0, 36.0]),
            const PathNode(PathDataCommand.lineTo, [48.0, 12.0]),
            const PathNode(PathDataCommand.lineTo, [80.0, 36.0]),
            const PathNode(PathDataCommand.lineTo, [80.0, 84.0]),
            const PathNode(PathDataCommand.lineTo, [53.0, 84.0]),
            const PathNode(PathDataCommand.lineTo, [53.0, 59.0]),
            const PathNode(PathDataCommand.lineTo, [43.0, 59.0]),
            const PathNode(PathDataCommand.lineTo, [43.0, 84.0]),
            const PathNode(PathDataCommand.lineTo, [16.0, 84.0]),
          ],
        ).build(),
      )
      .build();

  static final errorCircle = ImageVectorBuilder(24.0, 24.0)
      .addNode(
        VectorPathBuilder(
          [
            const PathNode(PathDataCommand.moveTo, [11.0, 15.0]),
            const PathNode(PathDataCommand.lineTo, [13.0, 15.0]),
            const PathNode(PathDataCommand.lineTo, [13.0, 17.0]),
            const PathNode(PathDataCommand.lineTo, [11.0, 17.0]),
            const PathNode(PathDataCommand.lineTo, [11.0, 15.0]),
            const PathNode(PathDataCommand.moveTo, [11.0, 7.0]),
            const PathNode(PathDataCommand.lineTo, [13.0, 7.0]),
            const PathNode(PathDataCommand.lineTo, [13.0, 13.0]),
            const PathNode(PathDataCommand.lineTo, [11.0, 13.0]),
            const PathNode(PathDataCommand.lineTo, [11.0, 7.0]),
            const PathNode(PathDataCommand.moveTo, [12.0, 2.0]),
            const PathNode(
              PathDataCommand.curveTo,
              [6.47, 2.0, 2.0, 6.5, 2.0, 12.0],
            ),
            const PathNode(
              PathDataCommand.arcTo,
              [10.0, 10.0, 0.0, false, false, 22.0, 12.0],
            ),
            const PathNode(
              PathDataCommand.arcTo,
              [10.0, 10.0, 0.0, false, false, 12.0, 2.0],
            ),
            const PathNode(PathDataCommand.moveTo, [12.0, 20.0]),
            const PathNode(
              PathDataCommand.arcTo,
              [8.0, 8.0, 0.0, false, true, 4.0, 12.0],
            ),
            const PathNode(
              PathDataCommand.arcTo,
              [8.0, 8.0, 0.0, true, true, 12.0, 20.0],
            ),
            const PathNode(PathDataCommand.close, []),
          ],
        ).build(),
      )
      .build();
}
