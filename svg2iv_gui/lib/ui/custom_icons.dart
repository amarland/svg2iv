import 'package:svg2iv_common/model/image_vector.dart';
import 'package:svg2iv_common/model/vector_path.dart';

class CustomIcons {
  CustomIcons._();

  static final faceIcon = ImageVectorBuilder(24.0, 24.0)
      .addNode(
        VectorPathBuilder(
          [
            const PathNode(PathDataCommand.moveTo, [10.25, 13.0]),
            const PathNode(
              PathDataCommand.relativeCurveTo,
              [0.0, 0.69, -0.56, 1.25, -1.25, 1.25],
            ),
            const PathNode(
              PathDataCommand.smoothCurveTo,
              [7.75, 13.69, 7.75, 13.0],
            ),
            const PathNode(
              PathDataCommand.relativeSmoothCurveTo,
              [0.56, -1.25, 1.25, -1.25],
            ),
            const PathNode(
              PathDataCommand.relativeSmoothCurveTo,
              [1.25, 0.56, 1.25, 1.25],
            ),
            const PathNode(PathDataCommand.close, []),
            const PathNode(PathDataCommand.moveTo, [15.0, 11.75]),
            const PathNode(
              PathDataCommand.relativeCurveTo,
              [-0.69, 0.0, -1.25, 0.56, -1.25, 1.25],
            ),
            const PathNode(
              PathDataCommand.relativeSmoothCurveTo,
              [0.56, 1.25, 1.25, 1.25],
            ),
            const PathNode(
              PathDataCommand.relativeSmoothCurveTo,
              [1.25, -0.56, 1.25, -1.25],
            ),
            const PathNode(
              PathDataCommand.relativeSmoothCurveTo,
              [-0.56, -1.25, -1.25, -1.25],
            ),
            const PathNode(PathDataCommand.close, []),
            const PathNode(PathDataCommand.moveTo, [22.0, 12.0]),
            const PathNode(
              PathDataCommand.relativeCurveTo,
              [0.0, 5.52, -4.48, 10.0, -10.0, 10.0],
            ),
            const PathNode(
              PathDataCommand.smoothCurveTo,
              [2.0, 17.52, 2.0, 12.0],
            ),
            const PathNode(
              PathDataCommand.smoothCurveTo,
              [6.48, 2.0, 12.0, 2.0],
            ),
            const PathNode(
              PathDataCommand.relativeSmoothCurveTo,
              [10.0, 4.48, 10.0, 10.0],
            ),
            const PathNode(PathDataCommand.close, []),
            const PathNode(PathDataCommand.moveTo, [10.66, 4.12]),
            const PathNode(
              PathDataCommand.curveTo,
              [12.06, 6.44, 14.6, 8.0, 17.5, 8.0],
            ),
            const PathNode(
              PathDataCommand.relativeCurveTo,
              [0.46, 0.0, 0.91, -0.05, 1.34, -0.12],
            ),
            const PathNode(
              PathDataCommand.curveTo,
              [17.44, 5.56, 14.9, 4.0, 12.0, 4.0],
            ),
            const PathNode(
              PathDataCommand.relativeCurveTo,
              [-0.46, 0.0, -0.91, 0.05, -1.34, 0.12],
            ),
            const PathNode(PathDataCommand.close, []),
            const PathNode(PathDataCommand.moveTo, [4.42, 9.47]),
            const PathNode(
              PathDataCommand.relativeCurveTo,
              [1.71, -0.97, 3.03, -2.55, 3.66, -4.44],
            ),
            const PathNode(
              PathDataCommand.curveTo,
              [6.37, 6.0, 5.05, 7.58, 4.42, 9.47],
            ),
            const PathNode(PathDataCommand.close, []),
            const PathNode(PathDataCommand.moveTo, [20.0, 12.0]),
            const PathNode(
              PathDataCommand.relativeCurveTo,
              [0.0, -0.78, -0.12, -1.53, -0.33, -2.24],
            ),
            const PathNode(
              PathDataCommand.relativeCurveTo,
              [-0.7, 0.15, -1.42, 0.24, -2.17, 0.24],
            ),
            const PathNode(
              PathDataCommand.relativeCurveTo,
              [-3.13, 0.0, -5.92, -1.44, -7.76, -3.69],
            ),
            const PathNode(
              PathDataCommand.curveTo,
              [8.69, 8.87, 6.6, 10.88, 4.0, 11.86],
            ),
            const PathNode(
              PathDataCommand.relativeCurveTo,
              [0.01, 0.04, 0.0, 0.09, 0.0, 0.14],
            ),
            const PathNode(
              PathDataCommand.relativeCurveTo,
              [0.0, 4.41, 3.59, 8.0, 8.0, 8.0],
            ),
            const PathNode(
              PathDataCommand.relativeSmoothCurveTo,
              [8.0, -3.59, 8.0, -8.0],
            ),
            const PathNode(PathDataCommand.close, []),
          ],
        ).build(),
      )
      .build();

  static final errorCircle = ImageVectorBuilder(24.0, 24.0)
      .addNode(
        VectorPathBuilder(
          [
            const PathNode(PathDataCommand.moveTo, [11.0, 15.0]),
            const PathNode(PathDataCommand.horizontalLineTo, [13.0]),
            const PathNode(PathDataCommand.verticalLineTo, [17.0]),
            const PathNode(PathDataCommand.horizontalLineTo, [11.0]),
            const PathNode(PathDataCommand.verticalLineTo, [15.0]),
            const PathNode(PathDataCommand.moveTo, [11.0, 7.0]),
            const PathNode(PathDataCommand.horizontalLineTo, [13.0]),
            const PathNode(PathDataCommand.verticalLineTo, [13.0]),
            const PathNode(PathDataCommand.horizontalLineTo, [11.0]),
            const PathNode(PathDataCommand.verticalLineTo, [7.0]),
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
