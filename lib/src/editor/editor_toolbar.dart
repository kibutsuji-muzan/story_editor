import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/controllers/story_editor_controller.dart';

class EditorToolbar extends StatelessWidget {
  final VoidCallback? onTapText;
  final VoidCallback? onTapStickers;
  final VoidCallback? onTapMusic;
  final VoidCallback? onTapProduct;
  final bool isAudioMuted;
  final VoidCallback? onToggleAudio;
  final bool hasVideo;

  const EditorToolbar({
    super.key,
    this.onTapText,
    this.onTapStickers,
    this.onTapMusic,
    this.onTapProduct,
    this.isAudioMuted = false,
    this.onToggleAudio,
    this.hasVideo = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StoryEditorController>();
    final canUndo = controller.history.canUndo;
    final canRedo = controller.history.canRedo;
    final hasTaggedProduct = controller.state.taggedProductId != 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(80),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withAlpha(40),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Undo
              _buildIconButton(
                icon: Icons.undo_rounded,
                onPressed: canUndo ? controller.undo : null,
                color: canUndo ? Colors.white : Colors.white24,
                tooltip: 'Undo',
              ),
              const SizedBox(width: 8),
              // Redo
              _buildIconButton(
                icon: Icons.redo_rounded,
                onPressed: canRedo ? controller.redo : null,
                color: canRedo ? Colors.white : Colors.white24,
                tooltip: 'Redo',
              ),
              _buildDivider(),
              // Text
              _buildIconButton(
                icon: Icons.text_fields_rounded,
                onPressed: onTapText,
                tooltip: 'Add Text',
              ),
              const SizedBox(width: 8),
              // Stickers
              _buildIconButton(
                icon: Icons.emoji_emotions_rounded,
                onPressed: onTapStickers,
                tooltip: 'Stickers & Emojis',
              ),
              const SizedBox(width: 8),
              // Music
              _buildIconButton(
                icon: Icons.music_note_rounded,
                onPressed: onTapMusic,
                tooltip: 'Add Music',
              ),
              const SizedBox(width: 8),
              // Tag Product
              _buildIconButton(
                icon: hasTaggedProduct
                    ? Icons.shopping_bag_rounded
                    : Icons.shopping_bag_outlined,
                onPressed: onTapProduct,
                color: hasTaggedProduct ? Colors.greenAccent : Colors.white,
                tooltip: 'Tag Product',
              ),
              if (hasVideo) ...[
                _buildDivider(),
                // Mute/Unmute
                _buildIconButton(
                  icon: isAudioMuted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  onPressed: onToggleAudio,
                  tooltip: 'Mute/Unmute Video',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    Color color = Colors.white,
    String? tooltip,
  }) {
    return IconButton(
      icon: Icon(icon, color: color, size: 24),
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        hoverColor: Colors.white12,
        highlightColor: Colors.white24,
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white24,
    );
  }
}
