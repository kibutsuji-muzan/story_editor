import 'package:flutter/material.dart';
import '../../core/controllers/story_editor_controller.dart';
import '../../core/models/text_layer.dart';
import '../../core/utils/layer_utils.dart';
import '../editor_plugin.dart';

class EmojiPlugin extends EditorPlugin {
  const EmojiPlugin()
      : super(
          id: 'emoji_plugin',
          name: 'Emojis',
          icon: Icons.face_retouching_natural_rounded,
        );

  @override
  void onTap(BuildContext context, StoryEditorController controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final List<String> emojis = ['😀', '😍', '🔥', '🎉', '👏', '😂', '👍', '❤️'];
        return Container(
          padding: const EdgeInsets.all(16),
          height: 150,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: emojis.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  controller.addLayer(
                    TextLayer(
                      id: LayerUtils.generateUniqueId('emoji'),
                      text: emojis[index],
                    ),
                  );
                },
                child: Center(
                  child: Text(
                    emojis[index],
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
