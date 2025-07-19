import 'package:alphabet_scroll_view/alphabet_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:wedband/Client.dart';
import 'package:wedband/ClientPage.dart';
import 'package:wedband/Configuration.dart';
import 'package:wedband/ItemService.dart';
import 'package:wedband/PdfItem.dart';
import 'package:wedband/PdfScreen.dart';
import 'package:wedband/Server.dart';
import 'package:wedband/ServerPage.dart';

class PdfListScreen extends StatefulWidget {
  Server? server;
  Client? client;

  PdfListScreen(this.server, this.client, {Key? key}) : super(key: key);

  @override
  State createState() {
    return _PdfListScreen(server, client);
  }
}

class _PdfListScreen extends State<PdfListScreen> {
  static const String title = 'Lista utworów';
  final List<int> colorCodes =
      List<int>.generate(1000, (i) => i % 2 == 0 ? 100 : 0);
  Server? server;
  Client? client;

  _PdfListScreen(this.server, this.client);

  @override
  void initState() {
    ItemService.setListOfFiles(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
              onPressed: () {
                if (server != null) {
                  Navigator.of(context).pop(MaterialPageRoute(
                      builder: (context) => ServerPage(server)));
                } else if (client != null) {
                  Navigator.of(context).pop(MaterialPageRoute(
                      builder: (context) => ClientPage(client)));
                }
              },
            ),
            title: const Text(title, style: TextStyle(color: Colors.black)),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    String selectedSong =
                        Provider.of<Configuration>(context, listen: false)
                            .getSongTitle();
                    viewPdf(selectedSong);
                  },
                  child: Text(
                      context.watch<Configuration>().getSongTitleShortcut(),
                      style:
                          const TextStyle(fontSize: 20, color: Colors.black))),
            ]),
        body: AlphabetScrollView(
            list: Provider.of<Configuration>(context, listen: false)
                .getPdfItems()
                .map((e) => AlphaModel(e.getTitle()))
                .toList(),
            itemExtent: 50,
            itemBuilder: (context, index, id) {
              return Container(
                height: 60,
                color: Colors.amber[colorCodes[index]],
                child: SizedBox(
                  height: 60,
                  child: TextButton(
                    onPressed: () {
                      viewPdf(Provider.of<Configuration>(context, listen: false)
                          .getPdfItems()[index]
                          .getTitle());
                    },
                    child: Text(
                        Provider.of<Configuration>(context, listen: false)
                            .getPdfItems()[index]
                            .getTitle(),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 30)),
                  ),
                ),
              );
            },
            selectedTextStyle:
                const TextStyle(fontSize: 30, color: Colors.black),
            unselectedTextStyle:
                const TextStyle(fontSize: 20, color: Colors.black)),
      ),
    );
  }

  void viewPdf(String name) {
    PdfItem? pdfItem = Provider.of<Configuration>(context, listen: false)
        .getPdfItemByTitle(name);
    if (pdfItem != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PdfScreen(pdfItem, server, client)));
    } else {
      showSimpleNotification(
          const Text('Nie posiadasz wybranego utworu w śpiewniku',
              style: TextStyle(fontSize: 20, color: Colors.black)),
          background: Colors.white);
      setState(() {
        ItemService.setListOfFiles(context);
      });
    }
  }
}
