import 'transform_data.dart';

enum LayerType { text, image, sticker, timer, polls, music }

abstract class EditorLayer {
  final String id;
  final TransformData transform;
  final LayerType type;

  EditorLayer({
    required this.id,
    TransformData? transform,
    required this.type,
  }) : transform = transform ?? TransformData();

  EditorLayer copyWith({
    String? id,
    TransformData? transform,
  });

  Map<String, dynamic> toJson();
}
