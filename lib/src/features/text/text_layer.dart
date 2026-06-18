import 'package:flutter/material.dart';
import '../../core/models/editor_layer.dart';
import '../../core/models/transform_data.dart';

class TextLayer extends EditorLayer {
  final String text;
  final String fontFamily;
  final Color color;

  TextLayer({
    required super.id,
    super.transform,
    required this.text,
    this.fontFamily = 'Inter',
    Color? color,
  }) : color = color ?? const Color(0xFFFFFFFF),
       super(type: LayerType.text);

  @override
  TextLayer copyWith({
    String? id,
    TransformData? transform,
    String? text,
    String? fontFamily,
    Color? color,
  }) {
    return TextLayer(
      id: id ?? this.id,
      transform: transform ?? this.transform,
      text: text ?? this.text,
      fontFamily: fontFamily ?? this.fontFamily,
      color: color ?? this.color,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'widget': 'text',
      'key': id,
      'font': fontFamily,
      'color': color.value,
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
      color: json['color'] != null ? Color(json['color'] as int) : null,
    );
  }
}
