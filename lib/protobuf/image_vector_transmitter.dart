import 'dart:io';

import 'package:svg2iv/protobuf/image_vector.pb.dart';

Future transmitProtobufImageVector(
  ImageVectorCollection imageVectors,
  InternetAddress host,
  int portNumber,
) async {
  final socket = await Socket.connect(host, portNumber);
  socket.add(imageVectors.writeToBuffer());
  return await socket.flush().then((_) => socket.destroy());
}
