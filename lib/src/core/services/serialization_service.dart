import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/editor_layer.dart';
import '../models/text_layer.dart';
import '../models/sticker_layer.dart';
import '../models/timer_layer.dart';
import '../models/polls_layer.dart';
import '../models/music_layer.dart';
import '../models/image_layer.dart';

class SerializationService {
  static List<EditorLayer> deserializeWidgets(List<dynamic> jsonList) {
    final List<EditorLayer> layers = [];
    for (final dynamic item in jsonList) {
      if (item is! Map<String, dynamic>) continue;

      final String widgetType = item['widget']?.toString() ?? '';

      try {
        if (widgetType.contains('text')) {
          layers.add(TextLayer.fromJson(item));
        } else if (widgetType.contains('gif') || widgetType.contains('sticker')) {
          layers.add(StickerLayer.fromJson(item));
        } else if (widgetType.contains('timer')) {
          layers.add(TimerLayer.fromJson(item));
        } else if (widgetType.contains('polls')) {
          layers.add(PollsLayer.fromJson(item));
        } else if (widgetType.contains('music')) {
          layers.add(MusicLayer.fromJson(item));
        } else if (widgetType.contains('image')) {
          layers.add(ImageLayer.fromJson(item));
        }
      } catch (e) {
        // Safe logging
        debugPrint('Error deserializing story layer: $e');
      }
    }
    return layers;
  }

  static String serializeState({
    required List<EditorLayer> layers,
    String username = 'dummy',
    int userId = 5,
  }) {
    final widgetsList = layers.map((layer) => layer.toJson()).toList();
    final data = {
      'user': {
        'username': username,
        'id': userId,
      },
      'widgets': widgetsList,
    };
    return json.encode(data);
  }
}
