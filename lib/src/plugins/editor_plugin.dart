import 'package:flutter/widgets.dart';
import '../core/controllers/story_editor_controller.dart';
import '../core/models/editor_layer.dart';

abstract class EditorPlugin {
  final String id;
  final String name;
  final IconData icon;

  const EditorPlugin({
    required this.id,
    required this.name,
    required this.icon,
  });

  Set<LayerType> get supportedLayerTypes => const {};

  Set<String> get supportedWidgetTypes => {id};

  bool supportsLayer(EditorLayer layer) {
    return supportedLayerTypes.contains(layer.type);
  }

  bool supportsJson(Map<String, dynamic> json) {
    final widgetType = json['widget']?.toString().toLowerCase();
    if (widgetType == null || widgetType.isEmpty) return false;

    return supportedWidgetTypes.any((type) {
      final normalizedType = type.toLowerCase();
      return widgetType == normalizedType ||
          widgetType.contains(normalizedType);
    });
  }

  EditorLayer createLayer();

  Widget buildLayer(BuildContext context, EditorLayer layer);

  Map<String, dynamic> toJson(EditorLayer layer);

  EditorLayer fromJson(Map<String, dynamic> json);

  Future<void> onTap(
    BuildContext context,
    StoryEditorController controller,
  ) async {}
}
