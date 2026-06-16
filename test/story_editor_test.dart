import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:story_editor/extensions/matrix_extension.dart';
import 'package:story_editor/story_editor.dart';
import 'package:vector_math/vector_math_64.dart';

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

  test('Matrix4Extension copyWithScaleAndTranslation helper', () {
    final matrix = Matrix4.identity()
      ..translate(10.0, 20.0)
      ..rotateZ(0.5)
      ..scale(2.0, 3.0);

    final modified = matrix.copyWithScaleAndTranslation(
      targetScaleX: 0.5,
      targetScaleY: 0.6,
      targetOffset: const Offset(100.0, 200.0),
    );

    expect(modified.offset, const Offset(100.0, 200.0));
    expect(modified.scaleX, closeTo(0.5, 1e-5));
    expect(modified.scaleY, closeTo(0.6, 1e-5));
    expect(modified.rotation, closeTo(0.5, 1e-5));
  });
}
