import 'dart:io' as io;

class PdfItem {
  String _title;
  io.File _file;

  PdfItem(this._title, this._file);

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
}
