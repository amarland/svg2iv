import 'package:svg2iv_common/models.dart';

class CustomIcons {
  CustomIcons._();

  static final home = ImageVectorBuilder(96.0, 96.0)
      .addNode(
        VectorPathBuilder(
          const [
            MoveToNode(22.0, 78.0),
            LineToNode(37.0, 78.0),
            LineToNode(37.0, 53.0),
            LineToNode(59.0, 53.0),
            LineToNode(59.0, 78.0),
            LineToNode(74.0, 78.0),
            LineToNode(74.0, 39.0),
            LineToNode(48.0, 19.5),
            LineToNode(22.0, 39.0),
            LineToNode(22.0, 78.0),
            MoveToNode(16.0, 84.0),
            LineToNode(16.0, 36.0),
            LineToNode(48.0, 12.0),
            LineToNode(80.0, 36.0),
            LineToNode(80.0, 84.0),
            LineToNode(53.0, 84.0),
            LineToNode(53.0, 59.0),
            LineToNode(43.0, 59.0),
            LineToNode(43.0, 84.0),
            LineToNode(16.0, 84.0),
          ],
        ).build(),
      )
      .build();

  static final errorCircle = ImageVectorBuilder(24.0, 24.0)
      .addNode(
        VectorPathBuilder(
          const [
            MoveToNode(11.0, 15.0),
            LineToNode(13.0, 15.0),
            LineToNode(13.0, 17.0),
            LineToNode(11.0, 17.0),
            LineToNode(11.0, 15.0),
            MoveToNode(11.0, 7.0),
            LineToNode(13.0, 7.0),
            LineToNode(13.0, 13.0),
            LineToNode(11.0, 13.0),
            LineToNode(11.0, 7.0),
            MoveToNode(12.0, 2.0),
            CurveToNode(6.47, 2.0, 2.0, 6.5, 2.0, 12.0),
            ArcToNode(
              rx: 10.0,
              ry: 10.0,
              angle: 0.0,
              largeArc: false,
              sweep: false,
              x: 22.0,
              y: 12.0,
            ),
            ArcToNode(
              rx: 10.0,
              ry: 10.0,
              angle: 0.0,
              largeArc: false,
              sweep: false,
              x: 12.0,
              y: 2.0,
            ),
            MoveToNode(12.0, 20.0),
            ArcToNode(
              rx: 8.0,
              ry: 8.0,
              angle: 0.0,
              largeArc: false,
              sweep: true,
              x: 4.0,
              y: 12.0,
            ),
            ArcToNode(
              rx: 8.0,
              ry: 8.0,
              angle: 0.0,
              largeArc: true,
              sweep: true,
              x: 12.0,
              y: 20.0,
            ),
            CloseNode(),
          ],
        ).build(),
      )
      .build();
}
