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
}
