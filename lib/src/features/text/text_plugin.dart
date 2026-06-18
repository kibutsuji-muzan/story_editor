import 'package:flutter/material.dart';
import 'package:story_editor/src/features/text/text_editor_sheet.dart';

import '../../core/controllers/story_editor_controller.dart';
import '../../core/models/editor_layer.dart';
import '../../core/services/dismissable_overlay.dart';
import '../../core/utils/layer_utils.dart';
import 'text_layer.dart';
import 'text_layer_widget.dart' show TextLayerWidget;
import '../../plugins/editor_plugin.dart';

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
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) {
          return StoryEditorOverlay(child: TextEditorSheet(controller: controller));
        },
      ),
    );
    // final textController = TextEditingController();
    // final result = await showDialog<String>(
    //   context: context,
    //   builder: (context) {
    //     return AlertDialog(
    //       title: const Text('Add text'),
    //       content: TextField(
    //         controller: textController,
    //         autofocus: true,
    //         decoration: const InputDecoration(hintText: 'Story text'),
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.of(context).pop(),
    //           child: const Text('Cancel'),
    //         ),
    //         FilledButton(
    //           onPressed: () {
    //             Navigator.of(context).pop(textController.text);
    //           },
    //           child: const Text('Add'),
    //         ),
    //       ],
    //     );
    //   },
    // );
    // textController.dispose();

    // if (result == null || result.trim().isEmpty) return;

    // controller.addLayer(
    //   TextLayer(id: LayerUtils.generateUniqueId('text'), text: result.trim()),
    // );
  }

  @override
  Widget buildLayer(BuildContext context, EditorLayer layer) {
    return TextLayerWidget(layer: layer as TextLayer);
  }
}
