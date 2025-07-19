import 'dart:io' as io;

class PdfItem {
  String _title;
  int _bpm = 120;
  io.File _file;

  PdfItem(this._title, this._file, this._bpm);

  void setFile(io.File value) {
    _file = value;
  }

  void setTitle(String value) {
    _title = value;
  }

  io.File getFile() {
    return _file;
  }

  String getTitle() {
    return _title;
  }

  void setBpm(int value) {
    if (value != null) {
      _bpm = value;
    }
  }

  int getBpm() {
    return _bpm;
  }
}
