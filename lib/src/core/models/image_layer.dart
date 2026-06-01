import 'editor_layer.dart';
import 'transform_data.dart';

class ImageLayer extends EditorLayer {
  final String path;

  ImageLayer({
    required super.id,
    super.transform,
    required this.path,
  }) : super(type: LayerType.image);

  @override
  ImageLayer copyWith({
    String? id,
    TransformData? transform,
    String? path,
  }) {
    return ImageLayer(
      id: id ?? this.id,
      transform: transform ?? this.transform,
      path: path ?? this.path,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'widget': 'image',
      'key': id,
      'path': path,
      'position': transform.toList(),
    };
  }

  factory ImageLayer.fromJson(Map<String, dynamic> json) {
    return ImageLayer(
      id: json['key']?.toString() ?? '',
      transform: json['position'] != null
          ? TransformData.fromList(json['position'])
          : TransformData(),
      path: json['path']?.toString() ?? '',
    );
  }
}
