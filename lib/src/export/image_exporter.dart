import 'dart:io';
import '../core/models/editor_state.dart';

class ImageExporter {
  const ImageExporter();

  Future<File> export(EditorState state, {required Directory outputDirectory}) async {
    final bgPath = state.backgroundPath;
    if (bgPath == null) throw Exception('No background image to export');

    final originalFile = File(bgPath);
    final File destinationFile = File('${outputDirectory.path}/file.jpg');

    if (!await originalFile.exists()) {
      throw Exception('Background image file does not exist at path: $bgPath');
    }

    // Return copied background file as-is (decoupled from native compressors)
    return originalFile.copy(destinationFile.path);
  }
}
