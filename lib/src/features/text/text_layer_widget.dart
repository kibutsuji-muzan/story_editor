import 'package:flutter/material.dart';
import 'package:story_editor/story_editor.dart';
import 'package:story_editor/src/features/text/text_editor_sheet.dart';
import '../../core/services/dismissable_overlay.dart';

class TextLayerWidget extends StatelessWidget {
  final TextLayer layer;

  const TextLayerWidget({super.key, required this.layer});

  @override
  Widget build(BuildContext context) {
    final font = layer.fontFamily;
    final storyFont = StoryEditorConfig.instance.fonts.firstWhere(
      (f) => f.name == font,
      orElse: () => StoryFont(
        name: 'default',
        styleBuilder: (style) => style.copyWith(fontFamily: font),
      ),
    );

    final baseStyle = TextStyle(
      color: layer.color,
      fontSize: 30,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.none,
    );
    final textStyle = storyFont.styleBuilder(baseStyle);

    return GestureDetector(
      onTap: () {
        final controller = StoryEditorScope.of(context, listen: false);
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) {
              return StoryEditorOverlay(
                child: TextEditorSheet(
                  controller: controller,
                  existingLayer: layer,
                ),
              );
            },
          ),
        );
      },
      child: Hero(
        tag: layer.id,
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text(
              layer.text,
              textAlign: TextAlign.center,
              style: textStyle,
            ),
          ),
        ),
      ),
    );
  }
}
