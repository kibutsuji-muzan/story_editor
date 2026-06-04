import 'package:flutter/widgets.dart';
import '../../core/models/editor_layer.dart';
import '../../plugins/plugin_registry.dart';

class LayerRenderer {
  static Widget render(EditorLayer layer, {PluginRegistry? registry}) {
    final activeRegistry = registry ?? PluginRegistry.instance;
    return Builder(
      builder: (context) => activeRegistry.buildLayer(context, layer),
    );
  }
}
