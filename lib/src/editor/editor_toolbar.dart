import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:story_editor/story_editor.dart';

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
    final controller = StoryEditorScope.of(context);
    final canUndo = controller.history.canUndo;
    final canRedo = controller.history.canRedo;
    final pluginRegistry = PluginRegistry.instance;
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(50),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.white.withAlpha(40), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //Undo
              _buildIconButton(
                icon: Icons.undo_rounded,
                onPressed: canUndo ? controller.undo : null,
                color: canUndo ? Colors.white : Colors.white24,
                tooltip: 'Undo',
              ),
              // Redo
              _buildIconButton(
                icon: Icons.redo_rounded,
                onPressed: canRedo ? controller.redo : null,
                color: canRedo ? Colors.white : Colors.white24,
                tooltip: 'Redo',
              ),
              _buildDivider(),
              ...pluginRegistry.plugins.map((plugin) {
                return _buildIconButton(
                  icon: plugin.icon,
                  onPressed: () => plugin.onTap(context, controller),
                  tooltip: plugin.name,
                );
              }),
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
      height: 1,
      width: 24,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white24,
    );
  }
}
