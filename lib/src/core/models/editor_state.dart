import 'editor_layer.dart';

class EditorState {
  final List<EditorLayer> layers;
  final String? backgroundPath;
  final bool isVideo;
  final int taggedProductId;

  const EditorState({
    this.layers = const [],
    this.backgroundPath,
    this.isVideo = false,
    this.taggedProductId = 0,
  });

  EditorState copyWith({
    List<EditorLayer>? layers,
    String? backgroundPath,
    bool? isVideo,
    int? taggedProductId,
  }) {
    return EditorState(
      layers: layers ?? this.layers,
      backgroundPath: backgroundPath ?? this.backgroundPath,
      isVideo: isVideo ?? this.isVideo,
      taggedProductId: taggedProductId ?? this.taggedProductId,
    );
  }
}
