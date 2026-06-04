import 'package:flutter/material.dart';

import '../../core/controllers/story_editor_controller.dart';
import '../../core/models/editor_layer.dart';
import '../../core/utils/layer_utils.dart';
import '../../features/text/text_layer.dart';
import '../../features/text/text_layer_widget.dart' show TextLayerWidget;
import '../editor_plugin.dart';

class TextPlugin extends EditorPlugin {
  const TextPlugin() : super(id: 'text', name: 'Text', icon: Icons.text_fields);

  @override
  Set<LayerType> get supportedLayerTypes => const {LayerType.text};

  @override
  Set<String> get supportedWidgetTypes => const {'text'};

  @override
  EditorLayer createLayer() => TextLayer(id: '', text: '');

  @override
  EditorLayer fromJson(Map<String, dynamic> json) {
    return TextLayer.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(EditorLayer layer) {
    return (layer as TextLayer).toJson();
  }

  @override
  Future<void> onTap(
    BuildContext context,
    StoryEditorController controller,
  ) async {
    final textController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add text'),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Story text'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(textController.text);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    textController.dispose();

    if (result == null || result.trim().isEmpty) return;

    controller.addLayer(
      TextLayer(id: LayerUtils.generateUniqueId('text'), text: result.trim()),
    );
  }

  @override
  Widget buildLayer(BuildContext context, EditorLayer layer) {
    return TextLayerWidget(layer: layer as TextLayer);
  }
}
