import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:wedband/Configuration.dart';

import 'DirectoryService.dart';
import 'PdfListScreen.dart';
import 'Server.dart';

class ServerPage extends StatefulWidget {
  Server? server;

  ServerPage(this.server, {Key? key}) : super(key: key);

  @override
  _ServerPageState createState() => _ServerPageState(this.server);
}

class _ServerPageState extends State<ServerPage> {
  TextEditingController textFieldIpController = TextEditingController();
  Server? server;

  _ServerPageState(this.server);

  @override
  void initState() {
    server = new Server('0.0.0.0', this.onData, this.onError);
  }

  onData(Uint8List data) {
    var downloadData = String.fromCharCodes(data).trim();
    Codec<String, String> base64Conventer = utf8.fuse(base64);
    String decoded = base64Conventer.decode(downloadData);
    decoded = decoded ?? '';
    if (server != null && server!.running) {
      server!.sendAll(downloadData);
    }
    Provider.of<Configuration>(context, listen: false).changeSongTitle(decoded);
    setState(() {});
  }

  onError(dynamic error) {
    print(error);
  }

  dispose() {
    if (server != null && server!.running) {
      server!.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LIVE BAND'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 30,
          ),
          onPressed: confirmReturn,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                if (server != null && server!.running) {
                  await server!.stop();
                } else {
                  server = new Server('0.0.0.0', this.onData, this.onError);
                  await server!.start();
                }
                setState(() {});
              },
              child: Container(
                color: Colors.white12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Host  ',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: server != null && server!.running
                            ? Colors.green
                            : Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                      padding: EdgeInsets.all(5),
                      child: Text(
                        server != null && server!.running ? 'ON' : 'OFF',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                await DirectoryService.setDirectoryPath(context);
              },
              child: Container(
                color: Colors.white12,
                child: const Center(
                  child: Text(
                    'Wybór katalogu z tekstami',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                String directory =
                    Provider.of<Configuration>(context, listen: false)
                        .getDirectory();
                if (directory.isEmpty) {
                  showSimpleNotification(
                      const Text('Nie wybrano katalogu z utworami!',
                          style: TextStyle(fontSize: 20, color: Colors.black)),
                      background: Colors.white);
                } else {
                  viewSonglist();
                }
              },
              child: Container(
                color: Colors.white12,
                child: Center(
                  child: Text(
                    'Lista utworów',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  confirmReturn() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("UWAGA"),
          content: Text("Opuszczenie tej strony spowoduje wyłączenie serwera"),
          actions: <Widget>[
            TextButton(
              child: Text("OK", style: TextStyle(color: Colors.red)),
              onPressed: () {
                if (server != null && server!.running) {
                  server!.stop();
                }
                WakelockPlus.disable();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            TextButton(
              child: Text("Anuluj", style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void viewSonglist() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PdfListScreen(server, null)));
  }
}
