import 'dart:io' as io;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:wedband/Configuration.dart';
import 'package:wedband/PdfItem.dart';

class ItemService {
  static void setListOfFiles(BuildContext buildContext) {
    List<PdfItem> items = [];
    String path =
        Provider.of<Configuration>(buildContext, listen: false).getDirectory();
    List listFile =
        io.Directory(path).listSync().where((e) => e is File).toList();
    for (var file in listFile) {
      items.add(
          PdfItem(extractNameFromFile(file), file, extractBpmFromFile(file)));
    }
    items = items
      ..sort((a, b) => comparePolish(a.getTitle().toLowerCase().trim(),
          b.getTitle().toLowerCase().trim()));
    Provider.of<Configuration>(buildContext, listen: false).setPdfList(items);
  }

  static String extractNameFromFile(io.File file) {
    if (Platform.isWindows) {
      return file.path
          .split('\\')
          .last
          .replaceAll(".pdf", "")
          .replaceAll(RegExp(r'\[.*?\]'), '')
          .trim();
    } else {
      return file.path
          .split('/')
          .last
          .replaceAll(RegExp(r'\[.*?\]'), '')
          .replaceAll(".pdf", "")
          .trim();
    }
  }

  static int extractBpmFromFile(io.File file) {
    RegExp regex = RegExp(r'\[(.*?)\]');
    Match? match = regex.firstMatch(file.path);
    if (match == null) {
      return 120;
    } else {
      return int.parse(match.group(1)!);
    }
  }

  static String _removeDiacritics(String input) {
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

  static int comparePolish(String a, String b) {
    String normalizedA = _removeDiacritics(a.toLowerCase().trim());
    String normalizedB = _removeDiacritics(b.toLowerCase().trim());
    return normalizedA.compareTo(normalizedB);
  }
}
