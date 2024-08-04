import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:wedband2/Client.dart';
import 'package:wedband2/Configuration.dart';
import 'package:wedband2/ItemService.dart';
import 'package:wedband2/PdfItem.dart';
import 'package:wedband2/PdfListScreen.dart';
import 'package:wedband2/Server.dart';

class PdfScreen extends StatefulWidget {
  PdfItem pdfItem;
  Server? server;
  Client? client;

  PdfScreen(this.pdfItem, this.server, this.client, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PdfScreen(pdfItem, server, client);
  }
}

class _PdfScreen extends State<PdfScreen> {
  PdfItem pdfItem;
  Server? server;
  Client? client;
  bool isButtonDisabled = false;

  PdfViewerController _pdfViewerController = PdfViewerController();

  _PdfScreen(this.pdfItem, this.server, this.client);

  @override
  void initState() {
    _pdfViewerController.zoomLevel = 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          // SfPdfViewer.file(pdfItem.getFile(), controller: _pdfViewerController),
          Container(
        height: MediaQuery.of(context).size.height,
        child: InteractiveViewer(
          panEnabled: true,
          child: SfPdfViewer.file(
            pdfItem.getFile(),
            controller: _pdfViewerController,
            pageLayoutMode: PdfPageLayoutMode.single,
            pageSpacing: 0.0,
          ),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () {
            Navigator.of(context).pop(MaterialPageRoute(
                builder: (context) => PdfListScreen(server, client)));
          },
        ),
        toolbarHeight: 50,
        actions: <Widget>[
          const Padding(padding: EdgeInsets.symmetric(horizontal: 30)),
          TextButton(
            onPressed: () {
              var songTitle = Provider.of<Configuration>(context, listen: false)
                  .getSongTitle();
              if (songTitle.isNotEmpty) {
                PdfItem? selected =
                    Provider.of<Configuration>(context, listen: false)
                        .getPdfItemByTitle(songTitle);
                if (selected != null) {
                  setState(() {
                    pdfItem.setTitle(selected.getTitle());
                    pdfItem.setFile(selected.getFile());
                  });
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
            },
            child: Text(
              context.watch<Configuration>().getSongTitleShortcut(),
              style: const TextStyle(fontSize: 30, color: Colors.black),
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20)),
          IconButton(
              onPressed: isButtonDisabled
                  ? null
                  : () {
                      Future.delayed(Duration(seconds: 1), () {
                        sendSongTitle();
                        setState(() {
                          isButtonDisabled = false;
                        });
                      });
                      setState(() {
                        isButtonDisabled = true;
                      });
                    },
              icon: const Icon(Icons.send, color: Colors.black, size: 40)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20)),
          IconButton(
              onPressed: () {
                _pdfViewerController.zoomLevel += 0.1;
              },
              icon: const Icon(Icons.zoom_in, color: Colors.black, size: 40)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20)),
          IconButton(
              onPressed: () {
                _pdfViewerController.zoomLevel -= 0.1;
              },
              icon: const Icon(
                Icons.zoom_out,
                color: Colors.black,
                size: 40,
              )),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20)),
        ],
      ),
    );
  }

  void sendSongTitle() {
    Codec<String, String> base64Converter = utf8.fuse(base64);
    String encoded = base64Converter.encode(pdfItem.getTitle());
    if (server != null) {
      server!.broadCast(encoded);
      Provider.of<Configuration>(context, listen: false)
          .changeSongTitle(pdfItem.getTitle());
    } else if (client != null) {
      client!.write(encoded);
      Provider.of<Configuration>(context, listen: false)
          .changeSongTitle(pdfItem.getTitle());
    }
  }
}
