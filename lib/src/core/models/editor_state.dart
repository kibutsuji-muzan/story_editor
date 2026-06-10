import 'package:story_editor/src/core/models/media_source.dart';

import 'editor_layer.dart';

class EditorState {
  final List<EditorLayer> layers;
  final MediaSource? background;
  final int taggedProductId;

  const EditorState({
    this.layers = const [],
    this.background,
    this.taggedProductId = 0,
  });

  EditorState copyWith({
    List<EditorLayer>? layers,
    MediaSource? background,
    int? taggedProductId,
  }) {
    return EditorState(
      layers: layers ?? this.layers,
      background: background ?? this.background,
      taggedProductId: taggedProductId ?? this.taggedProductId,
    );
  }
}
