import 'dart:io' as io;
import 'dart:io';

import 'package:alphabet_scroll_view/alphabet_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:wedband2/Client.dart';
import 'package:wedband2/ClientPage.dart';
import 'package:wedband2/Configuration.dart';
import 'package:wedband2/PdfItem.dart';
import 'package:wedband2/PdfScreen.dart';
import 'package:wedband2/Server.dart';
import 'package:wedband2/ServerPage.dart';

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
    listOfFiles();
  }

  void listOfFiles() {
    if (Provider.of<Configuration>(context, listen: false)
        .isEmptyPdfItemList()) {
      List<PdfItem> items = [];
      String path =
      Provider.of<Configuration>(context, listen: false).getDirectory();
      List listFile =
      io.Directory(path).listSync().where((e) => e is File).toList();
      for (var file in listFile) {
        items.add(PdfItem(extractNameFromFile(file), file));
      }
      items = items
        ..sort((a, b) => comparePolish(a.getTitle().toLowerCase().trim(),
            b.getTitle().toLowerCase().trim()));
      Provider.of<Configuration>(context, listen: false).setPdfList(items);
    }
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
                if(server != null) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => ServerPage()));
                } else if(client != null){
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => ClientPage()));
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
                .map((e) => AlphaModel(e.getTitle())).toList(),
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
                          .getPdfItems()[index].getTitle());
                    },
                    child: Text(Provider.of<Configuration>(context, listen: false)
                        .getPdfItems()[index].getTitle(),
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

  String extractNameFromFile(io.File file) {
    if (Platform.isWindows) {
      return file.path.split('\\').last.replaceAll(".pdf", "").trim();
    } else if (Platform.isIOS) {
      String fileName = file.path.split('/').last.replaceAll(".pdf", "").trim();
      if (fileName.endsWith(' 1')) {
        return fileName.substring(0, fileName.length - 2).trim();
      }
      return fileName;
    } else {
      return file.path.split('/').last.replaceAll(".pdf", "").trim();
    }
  }

  int comparePolish(String a, String b) {
    String normalizedA = _removeDiacritics(a.toLowerCase().trim());
    String normalizedB = _removeDiacritics(b.toLowerCase().trim());
    return normalizedA.compareTo(normalizedB);
  }

  String _removeDiacritics(String input) {
    final diacriticMap = {
      'ą': 'az',
      'ć': 'cz',
      'ę': 'ez',
      'ł': 'lz',
      'ń': 'nz',
      'ó': 'oz',
      'ś': 'sz',
      'ż': 'zzw',
      'ź': 'zzz',
    };

    return input.replaceAllMapped(
        RegExp(r'[ąćęłńóśżź]'), (match) => diacriticMap[match.group(0)]!);
  }

  void viewPdf(String name) {
    PdfItem? pdfItem = Provider.of<Configuration>(context, listen: false)
        .getPdfItemByTitle(name);
    if (pdfItem != null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => PdfScreen(pdfItem, server, client)));
    } else {
      showSimpleNotification(
          const Text('Nie posiadasz wybranego utworu w śpiewniku',
              style: TextStyle(fontSize: 20, color: Colors.black)),
          background: Colors.white);
    }
  }
}
