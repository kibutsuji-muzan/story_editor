import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ExportUtils {
  static Future<Directory> getStoryWorkDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final workplace = Directory('${tempDir.path}/story_pkg');
    if (!await workplace.exists()) {
      await workplace.create(recursive: true);
    }
    return workplace;
  }
}
