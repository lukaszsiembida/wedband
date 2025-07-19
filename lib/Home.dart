import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:wedband/Configuration.dart';
import 'package:wedband/ConfigurationUtils.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _metronom = false;

  initState() {
    initPermission();
    super.initState();
    initDirectory();
    initOptions();
  }

  void initPermission() async {
    await Permission.location.request();
    await [
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();
  }

  void initDirectory() async {
    String directory = await ConfigurationUtils.loadConstant('directory');
    Provider.of<Configuration>(context, listen: false)
        .changeDirectory(directory);
  }

  void initOptions() async {
    String metronom = await ConfigurationUtils.loadConstant('metronom');
    if ('true' == metronom) {
      setState(() {
        _metronom = true;
        Provider.of<Configuration>(context, listen: false)
            .setMetronomStatus(_metronom);
      });
    }
  }

  void _toggleChbxMetronom(bool? value) {
    setState(() {
      _metronom = value ?? false; // Update the state
      Provider.of<Configuration>(context, listen: false)
          .setMetronomStatus(_metronom);
      if (_metronom) {
        ConfigurationUtils.saveConstant('metronom', 'true');
      } else {
        ConfigurationUtils.saveConstant('metronom', 'false');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                WakelockPlus.enable();
                Navigator.of(context).pushNamed('client');
              },
              child: Container(
                color: Colors.white,
                child: const Center(
                    child: Text(
                  'Klient',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                )),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                WakelockPlus.enable();
                Navigator.of(context).pushNamed('server');
              },
              child: Container(
                color: Colors.white54,
                child: const Center(
                    child: Text(
                  'Serwer',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                )),
              ),
            ),
          ),
          Visibility(
              visible: Platform.isAndroid,
              child: Expanded(
                child: Container(
                    color: Colors.white,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Opcje:',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 20),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: _metronom,
                                  onChanged: _toggleChbxMetronom,
                                ),
                                Text(
                                  'Metronom',
                                  style: TextStyle(fontSize: 20),
                                )
                              ])
                        ])),
              )),
        ],
      ),
    );
  }
}
