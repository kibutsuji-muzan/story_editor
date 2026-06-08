import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:story_editor/story_editor.dart';

class EditorToolbar extends StatefulWidget {
  final VoidCallback? onTapClose;
  final ToolbarTheme? theme;

  const EditorToolbar({super.key, this.onTapClose, this.theme});

  @override
  State<EditorToolbar> createState() => _EditorToolbarState();
}

class _EditorToolbarState extends State<EditorToolbar> {
  final pluginRegistry = PluginRegistry.instance;
  bool showAllTools = false;
  late final ScrollController _scrollController;

  ToolbarTheme get theme => widget.theme ?? const ToolbarTheme();

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
          color: theme.activeIconColor,
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
              color: canUndo ? theme.activeIconColor : theme.inactiveIconColor,
              tooltip: 'Undo',
            ),
            // Redo
            _buildIconButton(
              icon: Icons.redo_rounded,
              onPressed: canRedo ? controller.redo : null,
              color: canRedo ? theme.activeIconColor : theme.inactiveIconColor,
              tooltip: 'Redo',
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                _buildBackDropFilter(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < pluginRegistry.plugins.length; i++)
                          if (i < 5 || showAllTools)
                            _buildIconButton(
                              icon: pluginRegistry.plugins[i].icon,
                              onPressed: () => pluginRegistry.plugins[i].onTap(
                                context,
                                controller,
                              ),
                              tooltip: pluginRegistry.plugins[i].name,
                              color: theme.activeIconColor,
                            ),
                      ],
                    ),
                  ),
                ),
                if (pluginRegistry.plugins.length > 5)
                  _buildIconButton(
                    size: Size(theme.buttonSize.width, 20),
                    icon: showAllTools
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    onPressed: () =>
                        setState(() => showAllTools = !showAllTools),
                    color: theme.activeIconColor,
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBackDropFilter({required Widget child}) {
    return ClipRRect(
      borderRadius: theme.barBorderRadius,
      child: AnimatedSize(
        alignment: Alignment.topCenter,
        duration: theme.animationDuration,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: theme.blurSigma,
            sigmaY: theme.blurSigma,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: context.screenHeight * theme.barMaxHeightFactor,
            ),
            // padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            decoration: BoxDecoration(
              color: theme.barColor,
              borderRadius: theme.barBorderRadius,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    Size? size,
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
    String? tooltip,
  }) {
    final effectiveSize = size ?? theme.buttonSize;
    return Container(
      width: effectiveSize.width,
      height: effectiveSize.height,
      margin: theme.buttonMargin,
      child: IconButton(
        style: IconButton.styleFrom(
          elevation: theme.buttonElevation,
          shadowColor: color,
          padding: EdgeInsets.all(0),
          hoverColor: theme.buttonHoverColor,
          backgroundColor: theme.buttonBackgroundColor,
          highlightColor: theme.buttonHighlightColor,
          disabledBackgroundColor: theme.buttonDisabledBackgroundColor,
          minimumSize: effectiveSize,
        ),
        icon: Icon(icon, color: color, size: theme.iconSize),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}
