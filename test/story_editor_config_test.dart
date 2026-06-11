import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:story_editor/story_editor.dart';

void main() {
  setUp(() {
    // Reset instance to default config before each test
    StoryEditorConfig.instance = const StoryEditorConfig();
  });

  test('StoryEditorConfig default properties', () {
    final config = StoryEditorConfig.instance;
    expect(config.maxLayersCount, 20);
    expect(config.minFontSize, 12.0);
    expect(config.maxFontSize, 100.0);
    expect(config.minScaleFactor, 0.5);
    expect(config.maxScaleFactor, 4.0);
    expect(config.enableText, isTrue);
    expect(config.enableImage, isTrue);
    expect(config.enableSticker, isTrue);
    expect(config.enableTimer, isTrue);
    expect(config.enablePolls, isTrue);
    expect(config.enableMusic, isTrue);

    expect(config.colors, isNotEmpty);
    expect(config.fonts, isNotEmpty);
  });

  test('StoryEditorController respects maxLayersCount limit', () {
    // Set max layers count to 2
    StoryEditorConfig.instance = const StoryEditorConfig(
      maxLayersCount: 2,
    );

    final controller = StoryEditorController();
    expect(controller.canAddLayer, isTrue);

    controller.addLayer(TextLayer(id: 'layer1', text: 'One'));
    expect(controller.layers.length, 1);
    expect(controller.canAddLayer, isTrue);

    controller.addLayer(TextLayer(id: 'layer2', text: 'Two'));
    expect(controller.layers.length, 2);
    // At limit now
    expect(controller.canAddLayer, isFalse);

    // Try adding a third layer
    controller.addLayer(TextLayer(id: 'layer3', text: 'Three'));
    // Length should remain 2
    expect(controller.layers.length, 2);
  });

  test('TextEditorsChoices maps fonts and colors correctly', () {
    final customFont = StoryFont(
      name: 'CustomFont',
      styleBuilder: (style) => style.copyWith(fontFamily: 'CustomFont'),
    );
    final customColor = const StoryColor(
      name: 'CustomColor',
      color: Color(0xFFFF0000),
    );

    StoryEditorConfig.instance = StoryEditorConfig(
      fonts: [customFont],
      colors: [customColor],
    );

    expect(TextEditorsChoices.fonts, [customFont]);
    expect(TextEditorsChoices.colors, [customColor]);
  });

  testWidgets('StoryEditor config parameter updates global singleton', (tester) async {
    final customConfig = const StoryEditorConfig(
      maxLayersCount: 5,
      enableMusic: false,
    );

    final controller = StoryEditorController();

    await tester.pumpWidget(
      MaterialApp(
        home: StoryEditor(
          controller: controller,
          config: customConfig,
        ),
      ),
    );

    expect(StoryEditorConfig.instance.maxLayersCount, 5);
    expect(StoryEditorConfig.instance.enableMusic, isFalse);
  });
}
