import 'dart:io';

import 'package:async/async.dart';
import 'package:svg2iv/image_vector_json_adapter.dart';
import 'package:svg2iv/image_vector_transmitter.dart';
import 'package:svg2iv_common/model/gradient.dart';
import 'package:svg2iv_common/model/image_vector.dart';
import 'package:svg2iv_common/model/vector_path.dart';
import 'package:test/test.dart';

void main() {
  test(
    'transmitImageVector successfully transmits an ImageVector as JSON',
    () async {
      final imageVectors = <ImageVector?>[
        ImageVectorBuilder(20.0, 20.0)
            .width(20.0)
            .height(20.0)
            .name('test')
            .addNode(
              VectorPathBuilder([
                PathNode(PathDataCommand.moveTo, [5.0, 5.0]),
                PathNode(PathDataCommand.lineTo, [15.0, 15.0]),
              ])
                  .fill(Gradient.fromArgb(0xFFAABBCC))
                  .fillAlpha(0.75)
                  .stroke(Gradient.fromArgb(0xFFDDEEFF))
                  .id('test_path')
                  .build(),
            )
            .build(),
        null,
      ];
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
      expect(buffer, imageVectors.toJson());
    },
  );
}
