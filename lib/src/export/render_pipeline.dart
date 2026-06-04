import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'image_exporter.dart';
import 'video_exporter.dart';
import '../core/models/editor_state.dart';
import '../core/services/serialization_service.dart';

class RenderPipeline {
  const RenderPipeline();

  Future<File> exportStory({
    required EditorState state,
    bool includeAudio = true,
  }) async {
    // 1. Create a workspace directory inside system temporary directory
    final tempDir = await getTemporaryDirectory();
    final workplace = await Directory(
      '${tempDir.path}/story_${DateTime.now().millisecondsSinceEpoch}',
    ).create(recursive: true);

    try {
      // 2. Export and compress the background media
      File backgroundFile;
      if (state.isVideo) {
        const exporter = VideoExporter();
        backgroundFile = await exporter.export(
          state,
          outputDirectory: workplace,
        );
      } else {
        const exporter = ImageExporter();
        backgroundFile = await exporter.export(
          state,
          outputDirectory: workplace,
        );
      }

      // 3. Serialize and save the EditorState as data.json
      final jsonFile = File('${workplace.path}/data.json');
      final serializedJson = SerializationService.serializeState(
        layers: state.layers,
      );
      await jsonFile.writeAsString(serializedJson);

      // 4. Create a ZIP package containing the media and metadata
      final filesToZip = [backgroundFile, jsonFile];
      final zipFile = File(
        '${tempDir.path}/story_${DateTime.now().millisecondsSinceEpoch}.zip',
      );

      // await ZipFile.createFromFiles(
      //   sourceDir: workplace,
      //   files: filesToZip,
      //   zipFile: zipFile,
      // );

      // 5. Clean up workplace
      await workplace.delete(recursive: true);

      return zipFile;
    } catch (e) {
      // Attempt cleanup on error
      if (await workplace.exists()) {
        await workplace.delete(recursive: true);
      }
      rethrow;
    }
  }
}
