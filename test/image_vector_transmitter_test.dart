import 'dart:io';

import 'package:async/async.dart';
import 'package:svg2iv/protobuf/image_vector.pb.dart';
import 'package:svg2iv/protobuf/image_vector_transmitter.dart';
import 'package:test/test.dart';

void main() {
  test(
    'transmitImageVector successfully transmits a Protobuf ImageVector',
    () async {
      final imageVectors = ImageVectorCollection(
        nullableImageVectors: [
          NullableImageVector(
            value: ImageVector(
              nodes: [
                VectorNode(
                  path: VectorPath(
                    pathNodes: [
                      PathNode(
                        command: PathNode_Command.MOVE_TO,
                        arguments: [
                          PathNode_Argument(coordinate: 10.0),
                          PathNode_Argument(coordinate: 20.0),
                        ],
                      )
                    ],
                    id: 'test_path',
                    fill: Brush(
                      linearGradient: Gradient(colors: [0xAABBCCDD]),
                    ),
                    fillAlpha: 0.75,
                  ),
                ),
              ],
              name: 'test',
              viewportWidth: 20,
              viewportHeight: 20,
              width: 20,
              height: 20,
            ),
          ),
          NullableImageVector(nothing: Null.NOTHING),
        ],
      );
      final serverSocket =
          await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      await transmitProtobufImageVector(
        imageVectors,
        InternetAddress.loopbackIPv4,
        serverSocket.port,
      );
      final socket = StreamQueue(await serverSocket.first);
      final buffer = <int>[];
      while (await socket.hasNext) {
        buffer.addAll(await socket.next);
      }
      await socket.cancel();
      await serverSocket.close();
      expect(ImageVectorCollection.fromBuffer(buffer), imageVectors);
    },
  );
}
