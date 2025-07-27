import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:wedband/Client.dart';
import 'package:wedband/Configuration.dart';
import 'package:wedband/ItemService.dart';
import 'package:wedband/PdfItem.dart';
import 'package:wedband/PdfListScreen.dart';
import 'package:wedband/Server.dart';

import 'MetronomService.dart';
import 'components/IconWithText.dart';

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

class _PdfScreen extends State<PdfScreen> with WidgetsBindingObserver {
  PdfItem pdfItem;
  Server? server;
  Client? client;
  bool isButtonDisabled = false;
  int _bpm = 120;
  bool _isPlaying = false;

  PdfViewerController _pdfViewerController = PdfViewerController();
  MetronomService _metronomService = MetronomService();

  _PdfScreen(this.pdfItem, this.server, this.client);

  @override
  void initState() {
    if (Provider.of<Configuration>(context, listen: false)
        .isCheckedMetronom()) {
      _metronomService.init();
    }
    _pdfViewerController.zoomLevel = 1;
    _bpm = pdfItem.getBpm();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (Provider.of<Configuration>(context, listen: false)
          .isCheckedMetronom()) {
        _metronomService.stop();
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            body: Column(children: [
              Expanded(
                // height: MediaQuery.of(context).size.height,
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
            ]),
            bottomNavigationBar: Visibility(
              visible: Provider.of<Configuration>(context, listen: false)
                  .isCheckedMetronom(),
              child: Container(
                height: 60,
                child: Row(children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (_bpm > 5) {
                          _bpm -= 5;
                          _metronomService.setBpm(_bpm);
                        }
                      });
                    },
                    icon: IconWithText(text: '-5'),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (_bpm > 1) {
                          _bpm -= 1;
                          _metronomService.setBpm(_bpm);
                        }
                      });
                    },
                    icon: IconWithText(text: '-1'),
                  ),
                  Text('Bpm: $_bpm',
                      style:
                          const TextStyle(fontSize: 20, color: Colors.black)),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _bpm += 1;
                        _metronomService.setBpm(_bpm);
                      });
                    },
                    icon: IconWithText(text: '+1'),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _bpm += 5;
                        _metronomService.setBpm(_bpm);
                      });
                    },
                    icon: IconWithText(text: '+5'),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 20)),
                  IconButton(
                      onPressed: () async {
                        onPressedPlay();
                      },
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow))
                ]),
              ),
            ),
            appBar: AppBar(
              leading: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                onPressed: () {
                  if (Provider.of<Configuration>(context, listen: false)
                      .isCheckedMetronom()) {
                    _metronomService.stop();
                    setState(() {
                      _isPlaying = false;
                    });
                  }
                  Navigator.of(context).pop(MaterialPageRoute(
                      builder: (context) => PdfListScreen(server, client)));
                },
              ),
              toolbarHeight: 50,
              actions: <Widget>[
                const Padding(padding: EdgeInsets.symmetric(horizontal: 30)),
                TextButton(
                  onPressed: () async {
                    loadSongOnScreen(context);
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
                    icon:
                        const Icon(Icons.send, color: Colors.black, size: 40)),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
                IconButton(
                    onPressed: () {
                      _pdfViewerController.zoomLevel += 0.1;
                    },
                    icon: const Icon(Icons.zoom_in,
                        color: Colors.black, size: 40)),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
                IconButton(
                    onPressed: () {
                      _pdfViewerController.zoomLevel -= 0.1;
                    },
                    icon: const Icon(
                      Icons.zoom_out,
                      color: Colors.black,
                      size: 40,
                    )),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 30)),
              ],
            )),
        onWillPop: () async {
          if (Provider.of<Configuration>(context, listen: false)
              .isCheckedMetronom()) {
            _metronomService.stop();
            setState(() {
              _isPlaying = false;
            });
          }
          return true;
        });
  }

  void loadSongOnScreen(BuildContext context) {
    var songTitle =
        Provider.of<Configuration>(context, listen: false).getSongTitle();
    if (songTitle.isNotEmpty) {
      PdfItem? selected = Provider.of<Configuration>(context, listen: false)
          .getPdfItemByTitle(songTitle);
      if (selected != null) {
        setState(() {
          pdfItem.setTitle(selected.getTitle());
          pdfItem.setFile(selected.getFile());
          pdfItem.setBpm(selected.getBpm());
          if (Provider.of<Configuration>(context, listen: false)
              .isCheckedMetronom()) {
            _bpm = pdfItem.getBpm();
            _metronomService.setBpm(_bpm);
          }
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

  void onPressedPlay() {
    if (_isPlaying) {
      _metronomService.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      _metronomService.play(_bpm == null ? 120 : _bpm);
      setState(() {
        _isPlaying = true;
      });
    }
  }
}
