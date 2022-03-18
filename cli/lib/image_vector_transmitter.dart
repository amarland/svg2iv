import 'dart:io';

import 'image_vector_json_adapter.dart';
import 'package:svg2iv_common/model/image_vector.dart';

Future transmitProtobufImageVector(
  Iterable<ImageVector?> imageVectors,
  InternetAddress host,
  int portNumber,
) async {
  final socket = await Socket.connect(host, portNumber);
  socket.add(imageVectors.toJson());
  return await socket.flush().then((_) => socket.destroy());
}
