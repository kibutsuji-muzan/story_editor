import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ExportService {
  static Future<Directory> getExportDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final exportDir = Directory('${tempDir.path}/story_exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }
}
