import 'package:flutter/cupertino.dart';

import 'PdfItem.dart';

class Configuration extends ChangeNotifier {
  String _directory = '';
  List<PdfItem> _pdfItemList = [];
  bool _isHuaweiDevice = false;
  String _songTitle = '';
  final List<String> alphabet = [];

  Configuration();

  String getDirectory() {
    return _directory;
  }

  bool isHuaweiDevice() {
    return _isHuaweiDevice;
  }

  void setHuaweiDevice(bool value) {
    _isHuaweiDevice = value;
    notifyListeners();
  }

  void changeDirectory(String directory) {
    _directory = directory;
    notifyListeners();
  }

  PdfItem? getPdfItemByTitle(String title) {
    for (var item in _pdfItemList) {
      if (item.getTitle().toLowerCase().trim() ==
          (title.toLowerCase().trim())) {
        return item;
      }
    }
    return null;
  }

  List<PdfItem> getPdfItems() {
    return _pdfItemList;
  }

  bool isEmptyPdfItemList() {
    return _pdfItemList.isEmpty;
  }

  void setPdfList(List<PdfItem> pdfList) {
    this._pdfItemList = pdfList;
  }

  String getSongTitle() {
    return _songTitle;
  }

  String getSongTitleShortcut() {
    if (_songTitle.length > 18) {
      return '${_songTitle.substring(0, 15)}...';
    } else {
      return _songTitle;
    }
  }

  void changeSongTitle(String title) {
    _songTitle = title;
    notifyListeners();
  }
}
