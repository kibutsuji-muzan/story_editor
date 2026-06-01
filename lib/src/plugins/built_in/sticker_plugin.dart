import 'package:flutter/material.dart';
import '../../core/controllers/story_editor_controller.dart';
import '../../core/models/sticker_layer.dart';
import '../../core/utils/layer_utils.dart';
import '../editor_plugin.dart';

class StickerPlugin extends EditorPlugin {
  const StickerPlugin()
      : super(
          id: 'sticker_plugin',
          name: 'Stickers',
          icon: Icons.layers_rounded,
        );

  @override
  void onTap(BuildContext context, StoryEditorController controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final List<String> stickerUrls = [
          'https://i.giphy.com/media/v1.Y2lkPTc5MGI3NjExM3ZtMnU1cnRxOHMxaDFmd243MHhpb3BqMnloam1wNjRsZmg5c21qMyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9cw/l0Exhc7S4E5Z6Hj4k/giphy.gif',
          'https://i.giphy.com/media/v1.Y2lkPTc5MGI3NjExM2ZtMnU1cnRxOHMxaDFmd243MHhpb3BqMnloam1wNjRsZmg5c21qMyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9cw/l0Exhc7S4E5Z6Hj4k/giphy.gif',
        ];

        return Container(
          padding: const EdgeInsets.all(16),
          height: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Preset Gifs', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: stickerUrls.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        controller.addLayer(
                          StickerLayer(
                            id: LayerUtils.generateUniqueId('sticker'),
                            url: stickerUrls[index],
                            isGif: true,
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.network(stickerUrls[index], fit: BoxFit.cover),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
