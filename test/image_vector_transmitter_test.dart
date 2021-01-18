// @dart=2.9

import 'dart:io';

import 'package:async/async.dart';
import 'package:svg2va/protobuf/image_vector.pb.dart';
import 'package:svg2va/protobuf/image_vector_transmitter.dart';
import 'package:test/test.dart';

void main() {
  test(
    'transmitImageVector successfully transmits a Protobuf ImageVector',
    () async {
      final imageVector = ImageVector(
        group: VectorGroup(
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
                fill: Gradient(colors: [0xAABBCCDD]),
                fillAlpha: 0.75,
              ),
            ),
          ],
          id: 'test_group',
        ),
        name: 'test',
        viewportWidth: 20,
        viewportHeight: 20,
        width: 20,
        height: 20,
      );
      final serverSocket =
          await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      await transmitProtobufImageVector(
        imageVector,
        InternetAddress.loopbackIPv4,
        serverSocket.port,
      );
      final socket = StreamQueue(await serverSocket.first);
      final buffer = <int>[];
      while (await socket.hasNext) {
        buffer.addAll(await socket.next);
      }
      await serverSocket.close();
      expect(ImageVector.fromBuffer(buffer), imageVector);
    },
  );
}
