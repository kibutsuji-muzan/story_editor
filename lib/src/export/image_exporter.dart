import 'dart:io';
import 'package:flutter/services.dart';
import '../core/models/editor_state.dart';
import '../core/models/media_source.dart';

class ImageExporter {
  const ImageExporter();

  Future<File> export(EditorState state, {required Directory outputDirectory}) async {
    final source = state.background;
    if (source == null) throw Exception('No background image to export');

    final File destinationFile = File('${outputDirectory.path}/file.jpg');

    if (source is FileMediaSource) {
      if (!await source.file.exists()) {
        throw Exception('Background image file does not exist at path: ${source.file.path}');
      }
      return source.file.copy(destinationFile.path);
    } else if (source is MemoryMediaSource) {
      await destinationFile.writeAsBytes(source.bytes);
      return destinationFile;
    } else if (source is AssetMediaSource) {
      final byteData = await rootBundle.load(source.path);
      await destinationFile.writeAsBytes(
        byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
      return destinationFile;
    } else if (source is NetworkMediaSource) {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(source.url));
      final response = await request.close();
      final List<int> bytes = [];
      await for (final chunk in response) {
        bytes.addAll(chunk);
      }
      await destinationFile.writeAsBytes(bytes);
      return destinationFile;
    } else {
      throw Exception('Unsupported MediaSource: ${source.runtimeType}');
    }
  }
}
