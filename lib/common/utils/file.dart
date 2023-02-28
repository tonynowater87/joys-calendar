import 'dart:async';
import 'dart:io';

import 'package:joys_calendar/common/extentions/NumberExtentions.dart';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<File> writeStringIntoFile(
      String fileStringContent, String fileName) async {
    try {
      var appDir = await getApplicationDocumentsDirectory();
      String filePath = "${appDir.path}/$fileName";
      File file = File(filePath);
      return await file.writeAsString(fileStringContent, flush: true);
    } catch (e) {
      return Future.error("write file error occur ($e)");
    }
  }

  static Future<String> calculateFileSize(
      String fileStringContent) async {
    try {
      var appDir = await getApplicationDocumentsDirectory();
      String filePath = "${appDir.path}/${DateTime.now().microsecondsSinceEpoch}";
      File file = File(filePath);
      final tempFile = await file.writeAsString(fileStringContent, flush: true);
      final tempFileLength = await tempFile.length();
      return Future.value(tempFileLength.bytesToFileSizeString());
    } catch (e) {
      return Future.error("write file error occur ($e)");
    }
  }
}
