import 'package:flutter/material.dart';
import '../../core/controllers/story_editor_controller.dart';
import '../../core/models/editor_layer.dart';
import '../../features/sticker/sticker_layer.dart';
import '../../features/sticker/sticker_layer_widget.dart';
import '../../core/utils/layer_utils.dart';
import '../editor_plugin.dart';

class StickerPlugin extends EditorPlugin {
  const StickerPlugin()
    : super(id: 'sticker', name: 'Stickers', icon: Icons.layers_rounded);

  @override
  Set<LayerType> get supportedLayerTypes => const {LayerType.sticker};

  @override
  Set<String> get supportedWidgetTypes => const {'sticker', 'gif'};

  @override
  EditorLayer createLayer() {
    return StickerLayer(id: '', url: '');
  }

  @override
  Widget buildLayer(BuildContext context, EditorLayer layer) {
    return StickerLayerWidget(layer: layer as StickerLayer);
  }

  @override
  Map<String, dynamic> toJson(EditorLayer layer) {
    return (layer as StickerLayer).toJson();
  }

  @override
  EditorLayer fromJson(Map<String, dynamic> json) {
    return StickerLayer.fromJson(json);
  }

  @override
  Future<void> onTap(
    BuildContext context,
    StoryEditorController controller,
  ) async {
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
              const Text(
                'Add Preset Gifs',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
                        child: Image.network(
                          stickerUrls[index],
                          fit: BoxFit.cover,
                        ),
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
