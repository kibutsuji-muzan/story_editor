import 'editor_layer.dart';
import 'transform_data.dart';

class MusicLayer extends EditorLayer {
  final String url;
  final String title;
  final String thumbnail;
  final String subtitle;

  MusicLayer({
    required super.id,
    super.transform,
    required this.url,
    required this.title,
    required this.thumbnail,
    required this.subtitle,
  }) : super(type: LayerType.music);

  @override
  MusicLayer copyWith({
    String? id,
    TransformData? transform,
    String? url,
    String? title,
    String? thumbnail,
    String? subtitle,
  }) {
    return MusicLayer(
      id: id ?? this.id,
      transform: transform ?? this.transform,
      url: url ?? this.url,
      title: title ?? this.title,
      thumbnail: thumbnail ?? this.thumbnail,
      subtitle: subtitle ?? this.subtitle,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'widget': 'music',
      'key': id,
      'link': url,
      'title': title,
      'thumbnail': thumbnail,
      'subtitle': subtitle,
      'position': transform.toList(),
    };
  }

  factory MusicLayer.fromJson(Map<String, dynamic> json) {
    return MusicLayer(
      id: json['key']?.toString() ?? '',
      transform: json['position'] != null
          ? TransformData.fromList(json['position'])
          : TransformData(),
      url: json['link']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
    );
  }
}
