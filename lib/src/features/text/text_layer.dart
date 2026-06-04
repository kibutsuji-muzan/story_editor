import '../../core/models/editor_layer.dart';
import '../../core/models/transform_data.dart';

class TextLayer extends EditorLayer {
  final String text;
  final String fontFamily;
  final String colorHex;

  TextLayer({
    required super.id,
    super.transform,
    required this.text,
    this.fontFamily = 'Inter',
    this.colorHex = '#FFFFFF',
  }) : super(type: LayerType.text);

  @override
  TextLayer copyWith({
    String? id,
    TransformData? transform,
    String? text,
    String? fontFamily,
    String? colorHex,
  }) {
    return TextLayer(
      id: id ?? this.id,
      transform: transform ?? this.transform,
      text: text ?? this.text,
      fontFamily: fontFamily ?? this.fontFamily,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'widget': 'text',
      'key': id,
      'font': fontFamily,
      'color': colorHex,
      'data': text,
      'position': transform.toList(),
    };
  }

  factory TextLayer.fromJson(Map<String, dynamic> json) {
    return TextLayer(
      id: json['key']?.toString() ?? '',
      transform: json['position'] != null
          ? TransformData.fromList(json['position'])
          : TransformData(),
      text: json['data']?.toString() ?? '',
      fontFamily: json['font']?.toString() ?? 'Inter',
      colorHex: json['color']?.toString() ?? '#FFFFFF',
    );
  }
}
