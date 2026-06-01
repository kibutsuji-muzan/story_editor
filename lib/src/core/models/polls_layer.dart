import 'editor_layer.dart';
import 'transform_data.dart';

class PollsLayer extends EditorLayer {
  final String question;
  final String option1;
  final String option2;

  PollsLayer({
    required super.id,
    super.transform,
    this.question = 'Some Text Here',
    this.option1 = 'Yes',
    this.option2 = 'No',
  }) : super(type: LayerType.polls);

  @override
  PollsLayer copyWith({
    String? id,
    TransformData? transform,
    String? question,
    String? option1,
    String? option2,
  }) {
    return PollsLayer(
      id: id ?? this.id,
      transform: transform ?? this.transform,
      question: question ?? this.question,
      option1: option1 ?? this.option1,
      option2: option2 ?? this.option2,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'widget': 'polls',
      'key': id,
      'question': question,
      'option1': option1,
      'option2': option2,
      'position': transform.toList(),
    };
  }

  factory PollsLayer.fromJson(Map<String, dynamic> json) {
    return PollsLayer(
      id: json['key']?.toString() ?? '',
      transform: json['position'] != null
          ? TransformData.fromList(json['position'])
          : TransformData(),
      question: json['question']?.toString() ?? 'Some Text Here',
      option1: json['option1']?.toString() ?? 'Yes',
      option2: json['option2']?.toString() ?? 'No',
    );
  }
}
