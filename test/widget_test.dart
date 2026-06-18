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
    await tester.drag(textFinder, Offset(0.0, 250.0));
    await tester.pumpAndSettle();

    // The layer should be removed from the controller on release
    expect(controller.layers.length, 0);
  });

  testWidgets('Layer snaps in, stays snapped on small drag, and snaps out on large drag', (WidgetTester tester) async {
    final controller = StoryEditorController();
    controller.addLayer(TextLayer(id: 'text_1', text: 'Drag Me'));

    await tester.pumpWidget(
      MaterialApp(
        home: StoryEditor(
          controller: controller,
        ),
      ),
    );

    final textFinder = find.text('Drag Me');
    final startLoc = tester.getCenter(textFinder);

    final gesture = await tester.startGesture(startLoc);
    
    // Drag down smoothly to the trash can zone (250 pixels down)
    for (int i = 0; i < 25; i++) {
      await gesture.moveBy(const Offset(0.0, 10.0));
      await tester.pump();
    }

    // The layer state should now be snapped. We verify this by looking for the
    // scaled state (scale: 0.3) of AnimatedScale.
    final scaleFinder = find.byType(AnimatedScale);
    final AnimatedScale scaleWidget = tester.widget(scaleFinder);
    expect(scaleWidget.scale, 0.3); // Verify snapped scale is active

    // Move slightly (less than 40 pixel critical snap out threshold)
    for (int i = 0; i < 3; i++) {
      await gesture.moveBy(const Offset(0.0, 5.0));
      await tester.pump();
    }
    
    final scaleWidget2 = tester.widget<AnimatedScale>(scaleFinder);
    expect(scaleWidget2.scale, 0.3); // Should still be snapped

    // Move significantly (more than 40 pixel critical snap out threshold)
    for (int i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(0.0, 5.0));
      await tester.pump();
    }

    final scaleWidget3 = tester.widget<AnimatedScale>(scaleFinder);
    expect(scaleWidget3.scale, 1.0); // Should snap out (scale restored to 1.0)

    await gesture.up();
    await tester.pumpAndSettle();
  });
}
