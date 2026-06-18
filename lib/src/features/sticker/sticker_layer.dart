import '../../core/models/editor_layer.dart';
import '../../core/models/transform_data.dart';

class StickerLayer extends EditorLayer {
  final String url;
  final bool isGif;

  StickerLayer({
    required super.id,
    super.transform,
    required this.url,
    this.isGif = false,
  }) : super(type: LayerType.sticker);

  @override
  StickerLayer copyWith({
    String? id,
    TransformData? transform,
    String? url,
    bool? isGif,
  }) {
    return StickerLayer(
      id: id ?? this.id,
      transform: transform ?? this.transform,
      url: url ?? this.url,
      isGif: isGif ?? this.isGif,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'widget': isGif ? 'gif' : 'sticker',
      'key': id,
      'link': url,
      'position': transform.toList(),
    };
  }

  factory StickerLayer.fromJson(Map<String, dynamic> json) {
    final String widgetType = json['widget']?.toString() ?? '';
    return StickerLayer(
      id: json['key']?.toString() ?? '',
      transform: json['position'] != null
          ? TransformData.fromList(json['position'])
          : TransformData(),
      url: json['link']?.toString() ?? '',
      isGif: widgetType.contains('gif'),
    );
  }
}
