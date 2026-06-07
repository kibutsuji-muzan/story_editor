import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:story_editor/story_editor.dart';

class EditorToolbar extends StatefulWidget {
  final VoidCallback? onTapText;
  final VoidCallback? onTapStickers;
  final VoidCallback? onTapMusic;
  final VoidCallback? onTapProduct;
  final bool isAudioMuted;
  final VoidCallback? onToggleAudio;
  final bool hasVideo;
  final VoidCallback? onTapClose;

  const EditorToolbar({
    super.key,
    this.onTapText,
    this.onTapStickers,
    this.onTapMusic,
    this.onTapProduct,
    this.isAudioMuted = false,
    this.onToggleAudio,
    this.hasVideo = false,
    this.onTapClose,
  });

  @override
  State<EditorToolbar> createState() => _EditorToolbarState();
}

class _EditorToolbarState extends State<EditorToolbar> {
  final pluginRegistry = PluginRegistry.instance;
  bool showAllTools = false;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = StoryEditorScope.of(context);
    final canUndo = controller.history.canUndo;
    final canRedo = controller.history.canRedo;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Close Button
        _buildIconButton(
          icon: Icons.close_rounded,
          onPressed:
              widget.onTapClose ?? () => Navigator.of(context).maybePop(),
          tooltip: 'Close',
        ),
        // Actions
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Undo
            _buildIconButton(
              icon: Icons.undo_rounded,
              onPressed: canUndo ? controller.undo : null,
              color: canUndo ? Colors.black : Colors.black54,
              tooltip: 'Undo',
            ),
            // Redo
            _buildIconButton(
              icon: Icons.redo_rounded,
              onPressed: canRedo ? controller.redo : null,
              color: canRedo ? Colors.black : Colors.black54,
              tooltip: 'Redo',
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.5,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                controller: _scrollController,
                child: Column(
                  children: [
                    _buildBackDropFilter(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (
                            int i = 0;
                            i < pluginRegistry.plugins.length;
                            i++
                          )
                            if (i < 5 || showAllTools)
                              _buildIconButton(
                                icon: pluginRegistry.plugins[i].icon,
                                onPressed: () => pluginRegistry.plugins[i]
                                    .onTap(context, controller),
                                tooltip: pluginRegistry.plugins[i].name,
                              ),
                        ],
                      ),
                    ),
                    if (pluginRegistry.plugins.length > 5)
                      _buildIconButton(
                        size: const Size(35, 20),
                        icon: showAllTools
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        onPressed: () =>
                            setState(() => showAllTools = !showAllTools),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBackDropFilter({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: AnimatedSize(
        alignment: Alignment.topCenter,
        duration: Duration(milliseconds: 500),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Container(
            constraints: BoxConstraints(maxHeight: context.screenHeight * 0.6),
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(85),
              borderRadius: BorderRadius.circular(100),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    Size? size = const Size(35, 35),
    required IconData icon,
    required VoidCallback? onPressed,
    Color color = Colors.black,
    String? tooltip,
  }) {
    return IconButton(
      style: IconButton.styleFrom(
        elevation: 2,
        shadowColor: color,
        padding: EdgeInsets.all(0),
        hoverColor: Colors.white12,
        backgroundColor: Colors.white,
        highlightColor: Colors.white24,
        disabledBackgroundColor: Colors.white,
        minimumSize: size,
      ),
      icon: Icon(icon, color: color, size: 18),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}
