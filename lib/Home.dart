import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:wedband2/Configuration.dart';
import 'package:wedband2/ConfigurationUtils.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  initState() {
    initPermission();
    initDirectory();
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
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
        ],
      ),
    );
  }
}
