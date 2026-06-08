import 'package:flutter/material.dart';
import 'package:story_editor/story_editor.dart';
import 'package:story_editor/src/features/text/text_editor_sheet.dart';
import '../../core/services/dismissable_overlay.dart';
import 'text_layer.dart';

class TextLayerWidget extends StatelessWidget {
  final TextLayer layer;

  const TextLayerWidget({super.key, required this.layer});

  bool _isPackageFont(String fontFamily) {
    const packageFonts = {
      'Inter',
      'AbrilFatface',
      'BebasNeue',
      'DancingScript',
      'KolkerBrush',
      'ProtestRevolution',
      'ProtestStrike',
      'RubikDoodleShadow',
      'RubikGlitchPop',
      'ZenTokyoZoo',
    };
    return packageFonts.contains(fontFamily);
  }

  @override
  Widget build(BuildContext context) {
    // Parse color safely
    Color textColor = Colors.white;
    try {
      final hex = layer.colorHex.replaceAll('#', '');
      textColor = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {}

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
      child: Text(
        layer.text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: layer.fontFamily,
          package: _isPackageFont(layer.fontFamily) ? 'story_editor' : null,
          color: textColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
