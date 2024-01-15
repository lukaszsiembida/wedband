import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'package:wedband2/Configuration.dart';
import 'package:wedband2/ConfigurationUtils.dart';

import 'PdfListScreen.dart';
import 'Server.dart';

class ServerPage extends StatefulWidget {
  @override
  _ServerPageState createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  late Server server;
  String textFieldIp = '';

  @override
  void initState() {
    createServer();
    super.initState();
  }

  void createServer() async {
    String ip = await ConfigurationUtils.loadConstant('server-ip');
    if(ip.isEmpty){
      ip = '0.0.0.0';
    }
    setState(() {
      textFieldIp = ip;
      server = Server(this.textFieldIp, this.onData, this.onError);
    });
  }

  onData(Uint8List data) {
    var downloadData = String.fromCharCodes(data).trim();
    Codec<String, String> base64Conventer = utf8.fuse(base64);
    String decoded = base64Conventer.decode(downloadData);
    decoded = decoded ?? '';
    server.sendAll(downloadData);
    Provider.of<Configuration>(context, listen: false).changeSongTitle(decoded);

    setState(() {});
  }

  onError(dynamic error) {
    print(error);
  }

  dispose() {
    server.stop();
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Serwer ip:',
                    style: TextStyle(color: Colors.black, fontSize: 30)),
                const Padding(padding: EdgeInsets.all(10)),
                SizedBox(
                  height: 60,
                  width: 200,
                  child: TextFormField(
                    initialValue: textFieldIp,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Serwer ip',
                        labelText: 'Serwer ip'),
                    onChanged: (text) {
                      setState(() {
                        textFieldIp = text;
                      });
                    },
                  ),
                ),
                Padding(padding: EdgeInsets.all(10)),
                OutlinedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0))),
                  ),
                  onPressed: () async {
                    writeServerIp(textFieldIp);
                  },
                  child: Text('Potwierdź',
                      style: TextStyle(color: Colors.black, fontSize: 30)),
                ),
              ],
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                if (server.running) {
                  await server.stop();
                } else {
                  await server.start();
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
                        color: server.running ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                      padding: EdgeInsets.all(5),
                      child: Text(
                        server.running ? 'ON' : 'OFF',
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
              onTap: () {
                viewSonglist();
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
                Navigator.of(context).pop();
                Navigator.of(context).pop();
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
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => PdfListScreen(server, null)));
  }

  void writeServerIp(String ip) async {
    if (server.running) {
      showSimpleNotification(
          Text('Nie można edytować ip gdy serwer jest uruchomiony!',
              style: TextStyle(fontSize: 20, color: Colors.black)),
          background: Colors.white);
    } else {
      if (validator.ip(ip) && !server.running) {
        ConfigurationUtils.saveConstant('server-ip', ip);
        showSimpleNotification(
            Text('Ip zostało zapisane',
                style: TextStyle(fontSize: 20, color: Colors.black)),
            background: Colors.white);
        setState(() {
          textFieldIp = ip;
          server = Server(ip, this.onData, this.onError);
        });
      } else {
        showSimpleNotification(
            Text('Błąd edycji ip',
                style: TextStyle(fontSize: 20, color: Colors.black)),
            background: Colors.white);
      }
    }
  }
}
