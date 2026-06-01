import 'editor_plugin.dart';

class PluginRegistry {
  final List<EditorPlugin> _plugins = [];

  List<EditorPlugin> get plugins => List.unmodifiable(_plugins);

  void register(EditorPlugin plugin) {
    if (!_plugins.any((p) => p.id == plugin.id)) {
      _plugins.add(plugin);
    }
  }

  void unregister(String id) {
    _plugins.removeWhere((p) => p.id == id);
  }
}
