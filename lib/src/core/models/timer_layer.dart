import 'editor_layer.dart';
import 'transform_data.dart';

class TimerLayer extends EditorLayer {
  final String duration;
  final String createdAt;

  TimerLayer({
    required super.id,
    super.transform,
    required this.duration,
    String? createdAt,
  })  : createdAt = createdAt ?? DateTime.now().toIso8601String(),
        super(type: LayerType.timer);

  @override
  TimerLayer copyWith({
    String? id,
    TransformData? transform,
    String? duration,
    String? createdAt,
  }) {
    return TimerLayer(
      id: id ?? this.id,
      transform: transform ?? this.transform,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'widget': 'timer',
      'key': id,
      'duration': duration,
      'createdAt': createdAt,
      'position': transform.toList(),
    };
  }

  factory TimerLayer.fromJson(Map<String, dynamic> json) {
    return TimerLayer(
      id: json['key']?.toString() ?? '',
      transform: json['position'] != null
          ? TransformData.fromList(json['position'])
          : TransformData(),
      duration: json['duration']?.toString() ?? '00:00:00',
      createdAt: json['createdAt']?.toString(),
    );
  }
}
