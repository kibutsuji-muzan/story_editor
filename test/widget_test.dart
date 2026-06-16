import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:story_editor/story_editor.dart';

void main() {
  testWidgets('StoryEditor renders close button and calls onTapClose', (WidgetTester tester) async {
    final controller = StoryEditorController();
    bool closeTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: StoryEditor(
          controller: controller,
          onTapClose: () {
            closeTapped = true;
          },
        ),
      ),
    );

    // Verify close button is present by finding the IconButton with the close tooltip
    final closeFinder = find.byTooltip('Close');
    expect(closeFinder, findsOneWidget);

    // Tap the close button
    await tester.tap(closeFinder);
    await tester.pump();

    // Verify callback was triggered
    expect(closeTapped, isTrue);
  });

  testWidgets('Dragging layer near trash can removes it on release', (WidgetTester tester) async {
    final controller = StoryEditorController();
    controller.addLayer(TextLayer(id: 'text_1', text: 'Drag Me'));

    await tester.pumpWidget(
      MaterialApp(
        home: StoryEditor(
          controller: controller,
        ),
      ),
    );

    expect(controller.layers.length, 1);

    // Find the layer
    final textFinder = find.text('Drag Me');
    expect(textFinder, findsOneWidget);

    // Drag the layer to the bottom center (trash can location)
    // The screen size is 800x600 by default in tests.
    // We drag it from its initial center to the bottom center.
    final firstLocation = tester.getCenter(textFinder);
    await tester.drag(textFinder, Offset(0.0, 250.0));
    await tester.pumpAndSettle();

    // The layer should be removed from the controller on release
    expect(controller.layers.length, 0);
  });
}
