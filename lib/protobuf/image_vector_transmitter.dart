// @dart=2.9

import 'dart:io';

import 'package:svg2va/protobuf/image_vector.pb.dart';

Future transmitProtobufImageVector(
  ImageVector imageVector,
  InternetAddress host,
  int portNumber,
) async {
  final socket = await Socket.connect(host, portNumber);
  socket.add(imageVector.writeToBuffer());
  await socket.flush();
  return await socket.destroy();
}
