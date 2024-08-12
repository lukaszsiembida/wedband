import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'package:wedband/Configuration.dart';

import 'Client.dart';
import 'DirectoryService.dart';
import 'PdfListScreen.dart';

class ClientPage extends StatefulWidget {
  Client? client;

  ClientPage(this.client, {Key? key}) : super(key: key);

  @override
  _ClientPageState createState() => _ClientPageState(this.client);
}

class _ClientPageState extends State<ClientPage> {
  Client? client;
  TextEditingController textFieldIpController = TextEditingController();

  _ClientPageState(this.client);

  @override
  void initState() {
    if (client == null || client!.connected == false) {
      createClient();
    } else {
      textFieldIpController.text = client!.hostname;
    }
  }

  void createClient() async {
    final info = NetworkInfo();
    String? wifi = await info.getWifiGatewayIP();
    String ip = wifi != null ? wifi : '192.168.';
    setState(() {
      textFieldIpController.text = ip;
      client = Client(ip, 4040, this.onData, this.onError);
    });
  }

  onData(Uint8List data) {
    var downloadData = new String.fromCharCodes(data).trim();
    Codec<String, String> base64Conventer = utf8.fuse(base64);
    String decoded = base64Conventer.decode(downloadData);
    decoded = decoded ?? '';
    Provider.of<Configuration>(context, listen: false).changeSongTitle(decoded);
    setState(() {});
  }

  onError(dynamic error) {
    print(error);
  }

  dispose() {
    if (client != null && client!.connected) {
      client!.disconnect();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BAND APP'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: confirmReturn,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Serwer ip:',
                        style: TextStyle(color: Colors.black, fontSize: 30)),
                    Padding(padding: EdgeInsets.all(10)),
                    SizedBox(
                      height: 60,
                      width: 200,
                      child: TextFormField(
                        key: UniqueKey(),
                        controller: textFieldIpController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Serwer ip',
                            labelText: 'Serwer ip'),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0))),
                      ),
                      onPressed: () async {
                        writeServerIp(textFieldIpController.text);
                      },
                      child: Text('Potwierdź',
                          style: TextStyle(color: Colors.black, fontSize: 30)),
                    )
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                if (client != null && client!.connected) {
                  await client!.disconnect();
                } else {
                  client = new Client(textFieldIpController.text, 4040,
                      this.onData, this.onError);
                  await client!.connect();
                }
                setState(() {});
              },
              child: Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Klient  ',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: client != null && client!.connected
                            ? Colors.green
                            : Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                      padding: EdgeInsets.all(5),
                      child: Text(
                        client != null && client!.connected
                            ? 'POŁĄCZONY'
                            : 'NIEPOWIĄZANY',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
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
          content: Text("Opuszczenie tej strony spowoduje wyłączenie klienta"),
          actions: <Widget>[
            TextButton(
              child: Text("OK", style: TextStyle(color: Colors.red)),
              onPressed: () {
                if (client != null && client!.connected) {
                  client!.disconnect();
                }
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
        MaterialPageRoute(builder: (context) => PdfListScreen(null, client)));
  }

  void writeServerIp(String ip) async {
    if (validator.ip(ip)) {
      showSimpleNotification(
          Text('Ip zostało zapisane',
              style: TextStyle(
                fontSize: 10,
                color: Colors.black,
              )),
          background: Colors.white);
      setState(() {
        textFieldIpController.text = ip;
        client = Client(ip, 4040, this.onData, this.onError);
      });
    } else {
      showSimpleNotification(
          Text('Błąd edycji ip',
              style: TextStyle(fontSize: 10, color: Colors.black)),
          background: Colors.white);
    }
  }
}
