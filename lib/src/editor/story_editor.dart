import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/controllers/story_editor_controller.dart';
import 'story_canvas.dart';
import 'editor_toolbar.dart';

class StoryEditor extends StatelessWidget {
  final StoryEditorController controller;
  final VoidCallback? onTapText;
  final VoidCallback? onTapStickers;
  final VoidCallback? onTapMusic;
  final VoidCallback? onTapProduct;
  final bool isAudioMuted;
  final VoidCallback? onToggleAudio;

  const StoryEditor({
    super.key,
    required this.controller,
    this.onTapText,
    this.onTapStickers,
    this.onTapMusic,
    this.onTapProduct,
    this.isAudioMuted = false,
    this.onToggleAudio,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StoryEditorController>.value(
      value: controller,
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0),
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // Main Canvas
              // Container(color: Colors.white, width: 100, height: 100),
              StoryCanvas(),

              // Floating Toolbar at Top Center
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: EditorToolbar(
                    onTapText: onTapText,
                    onTapStickers: onTapStickers,
                    onTapMusic: onTapMusic,
                    onTapProduct: onTapProduct,
                    isAudioMuted: isAudioMuted,
                    onToggleAudio: onToggleAudio,
                    hasVideo: controller.state.isVideo,
                  ),
                ),
              ),

              // Product Tag Indicator at Bottom Left
              Consumer<StoryEditorController>(
                builder: (context, controller, child) {
                  final productId = controller.state.taggedProductId;
                  if (productId == 0) return const SizedBox();
                  return Positioned(
                    bottom: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.shopping_bag_rounded,
                            color: Colors.greenAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tagged: #$productId',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
