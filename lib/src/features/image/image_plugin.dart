import 'package:flutter/material.dart';

import '../../../story_editor.dart';
import '../../core/controllers/story_editor_controller.dart';
import '../../core/models/editor_layer.dart';
import '../../features/image/image_layer.dart';
import '../../features/image/image_layer_widget.dart';

class ImagePlugin extends EditorPlugin {
  const ImagePlugin()
    : super(id: 'image', name: 'Image', icon: Icons.image_rounded);

  @override
  Set<LayerType> get supportedLayerTypes => const {LayerType.image};

  @override
  Set<String> get supportedWidgetTypes => const {'image'};

  @override
  EditorLayer createLayer() => ImageLayer(id: '', path: '');

  @override
  Widget buildLayer(BuildContext context, EditorLayer layer) {
    return ImageLayerWidget(layer: layer as ImageLayer);
  }

  @override
  Map<String, dynamic> toJson(EditorLayer layer) {
    return (layer as ImageLayer).toJson();
  }

  @override
  EditorLayer fromJson(Map<String, dynamic> json) {
    return ImageLayer.fromJson(json);
  }

  @override
  Future<void> onTap(
    BuildContext context,
    StoryEditorController controller,
  ) async {}
}
