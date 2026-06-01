import 'dart:io';
import '../core/models/editor_state.dart';

class VideoExporter {
  final bool includeAudio;

  const VideoExporter({this.includeAudio = true});

  Future<File> export(EditorState state, {required Directory outputDirectory}) async {
    final bgPath = state.backgroundPath;
    if (bgPath == null) throw Exception('No background video to export');

    final originalFile = File(bgPath);
    final File destinationFile = File('${outputDirectory.path}/file.mp4');

    if (!await originalFile.exists()) {
      throw Exception('Background video file does not exist at path: $bgPath');
    }

    return originalFile.copy(destinationFile.path);
  }
}
