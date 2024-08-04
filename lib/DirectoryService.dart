import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'Configuration.dart';
import 'ConfigurationUtils.dart';

class DirectoryService {

  static Future<void> setDirectoryPath(BuildContext context) async {
    String? directory = await FilePicker.platform.getDirectoryPath();
    if (directory != null) {
      Provider.of<Configuration>(context, listen: false)
          .changeDirectory(directory);
      ConfigurationUtils.saveConstant('directory', directory);
    }
  }
}
