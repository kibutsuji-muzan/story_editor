import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/editor_layer.dart';
import '../../plugins/plugin_registry.dart';

class SerializationService {
  static List<EditorLayer> deserializeWidgets(
    List<dynamic> jsonList, {
    PluginRegistry? registry,
  }) {
    final activeRegistry = registry ?? PluginRegistry.instance;
    final List<EditorLayer> layers = [];
    for (final dynamic item in jsonList) {
      if (item is! Map) continue;
      final json = Map<String, dynamic>.from(item);

      try {
        final layer = activeRegistry.fromJson(json);
        if (layer != null) {
          layers.add(layer);
        }
      } catch (e) {
        debugPrint('Error deserializing story layer: $e');
      }
    }
    return layers;
  }

  static String serializeState({
    required List<EditorLayer> layers,
    String username = 'dummy',
    int userId = 5,
    PluginRegistry? registry,
  }) {
    final activeRegistry = registry ?? PluginRegistry.instance;
    final widgetsList = layers.map(activeRegistry.toJson).toList();
    final data = {
      'user': {'username': username, 'id': userId},
      'widgets': widgetsList,
    };
    return json.encode(data);
  }
}
