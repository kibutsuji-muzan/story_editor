import 'package:flutter/widgets.dart';
import 'package:story_editor/src/features/image/image_plugin.dart';

import 'editor_plugin.dart';
import '../features/music/music_plugin.dart';
import '../features/polls/polls_plugin.dart';
import '../features/sticker/sticker_plugin.dart';
import '../features/text/text_plugin.dart';
import '../features/timer/timer_plugin.dart';
import '../core/models/editor_layer.dart';
import '../core/controllers/story_editor_controller.dart';

class PluginRegistry {
  static final PluginRegistry instance = PluginRegistry.builtIn();

  final List<EditorPlugin> _plugins = [];

  PluginRegistry({Iterable<EditorPlugin> plugins = const []}) {
    registerAll(plugins);
  }

  factory PluginRegistry.builtIn() {
    return PluginRegistry(
      plugins: const [
        StickerPlugin(),
        ImagePlugin(),
        TimerPlugin(),
        PollsPlugin(),
        MusicPlugin(),
        TextPlugin(),
      ],
    );
  }

  List<EditorPlugin> get plugins => List.unmodifiable(_plugins);

  void register(EditorPlugin plugin) {
    if (!_plugins.any((p) => p.id == plugin.id)) {
      _plugins.add(plugin);
    }
  }

  void registerAll(Iterable<EditorPlugin> plugins) {
    for (final plugin in plugins) {
      register(plugin);
    }
  }

  void unregister(String id) {
    _plugins.removeWhere((p) => p.id == id);
  }

  EditorPlugin? pluginForId(String id) {
    for (final plugin in _plugins) {
      if (plugin.id == id) return plugin;
    }
    return null;
  }

  EditorPlugin? pluginForLayer(EditorLayer layer) {
    for (final plugin in _plugins) {
      if (plugin.supportsLayer(layer)) return plugin;
    }
    return null;
  }

  EditorPlugin? pluginForJson(Map<String, dynamic> json) {
    for (final plugin in _plugins) {
      if (plugin.supportsJson(json)) return plugin;
    }
    return null;
  }

  Widget buildLayer(BuildContext context, EditorLayer layer) {
    return pluginForLayer(layer)?.buildLayer(context, layer) ??
        const SizedBox.shrink();
  }

  Map<String, dynamic> toJson(EditorLayer layer) {
    return pluginForLayer(layer)?.toJson(layer) ?? layer.toJson();
  }

  EditorLayer? fromJson(Map<String, dynamic> json) {
    return pluginForJson(json)?.fromJson(json);
  }

  Future<bool> handleTap(
    String id,
    BuildContext context,
    StoryEditorController controller,
  ) async {
    final plugin = pluginForId(id);
    if (plugin == null) return false;

    await plugin.onTap(context, controller);
    return true;
  }
}
