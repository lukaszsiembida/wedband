import 'dart:io';
import 'dart:typed_data';

import 'models.dart';

class Client {
  Client(
    this.hostname,
    this.port,
    this.onData,
    this.onError,
  );

  String hostname;
  int port;
  Uint8ListCallback onData;
  DynamicCallback onError;
  bool connected = false;
  String data = '';

  late Socket socket;

  connect() async {
    try {
      socket = await Socket.connect(hostname, 4040);
      socket.listen(
        onData,
        onError: onError,
        onDone: disconnect,
        cancelOnError: false,
      );
      connected = true;
    } on Exception catch (exception) {
      onData(Uint8List.fromList("Error : $exception".codeUnits));
    }
  }

  write(String message) {
    onData(Uint8List.fromList('$message'.codeUnits));
    socket.write(message);
  }

  disconnect() {
    if (socket !=  null) {
      socket.destroy();
      connected = false;
    }
  }
}
