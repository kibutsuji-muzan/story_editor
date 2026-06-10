import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:story_editor/story_editor.dart';

void main() {
  test('TransformData initialization', () {
    final transform = TransformData();
    expect(transform.matrix.isIdentity(), isTrue);
  });

  test('PluginRegistry deserializes built-in layers', () {
    final registry = PluginRegistry.builtIn();
    final layer = registry.fromJson({
      'widget': 'timer',
      'key': 'timer_1',
      'duration': '00:00:10',
      'position': TransformData().toList(),
    });

    expect(layer, isA<TimerLayer>());
    expect(layer?.id, 'timer_1');
  });

  test('SerializationService round-trips through plugin registry', () {
    final registry = PluginRegistry.builtIn();
    final serialized = SerializationService.serializeState(
      registry: registry,
      layers: [
        TextLayer(id: 'text_1', text: 'Hello'),
        StickerLayer(id: 'sticker_1', url: 'https://example.com/a.gif'),
      ],
    );

    final json = jsonDecode(serialized) as Map<String, dynamic>;
    final layers = SerializationService.deserializeWidgets(
      json['widgets'] as List<dynamic>,
      registry: registry,
    );

    expect(layers, hasLength(2));
    expect(layers[0], isA<TextLayer>());
    expect(layers[1], isA<StickerLayer>());
  });

  test('StoryEditorController background state updates', () {
    final controller = StoryEditorController();
    expect(controller.state.background, isNull);

    final fileSource = FileMediaSource(File('dummy.mp4'), type: MediaType.video);
    controller.setBackground(fileSource);

    expect(controller.state.background, fileSource);
    expect(controller.state.background?.type, MediaType.video);
    expect(controller.state.background, isA<FileMediaSource>());
  });
}
