import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'Models.dart';

class Server {

  Server(this.ip, this.onData, this.onError);
  String ip;
  Uint8ListCallback onData;
  String data = '';
  DynamicCallback onError;
  ServerSocket? server;
  bool running = false;
  List<Socket> sockets = [];

  start() async {
    runZoned(() async {
      server = await ServerSocket.bind(ip, 4040);
      running = true;
      server!.listen(onRequest);
      onData(Uint8List.fromList(''.codeUnits));
    }, onError: (e) {
      onError(e);
    });
  }


  stop() async {
    await server!.close();
    server = null;
    running = false;
  }

  broadCast(String message) {
    this.onData(Uint8List.fromList('$message'.codeUnits));
    for (Socket socket in sockets) {
      socket.write(message);
    }
  }

  sendAll(String message) {
    for (Socket socket in sockets) {
      socket.write(message);
    }
  }

  onRequest(Socket socket) {
    if (!sockets.contains(socket)) {
      sockets.add(socket);
    }
    socket.listen((Uint8List data) {
      this.onData(data);
    });
  }
}