import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:story_editor/story_editor.dart';
import '../layers/widgets/layer_frame.dart';
import '../layers/renderers/layer_renderer.dart';
import '../plugins/plugin_registry.dart';

class StoryCanvas extends StatefulWidget {
  final PluginRegistry? pluginRegistry;

  const StoryCanvas({super.key, this.pluginRegistry});

  @override
  State<StoryCanvas> createState() => _StoryCanvasState();
}

class _StoryCanvasState extends State<StoryCanvas> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = StoryEditorScope.of(context);
    final state = controller.state;

    if (state.isVideo && state.backgroundPath != null) {
      if (_videoController == null ||
          _videoController!.dataSource != state.backgroundPath) {
        _disposeVideo();
        _initializeVideo(state.backgroundPath!);
      }
    } else {
      _disposeVideo();
    }
  }

  void _initializeVideo(String path) {
    if (path.startsWith('http')) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(path));
    } else {
      _videoController = VideoPlayerController.file(File(path));
    }

    _videoController?.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        _videoController?.setLooping(true);
        _videoController?.play();
      }
    });
  }

  void _disposeVideo() {
    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;
    _isVideoInitialized = false;
  }

  Widget _buildBackgroundImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.cover);
    } else if (path.startsWith('assets/') || !path.startsWith('/')) {
      final isPackageAsset = path == 'assets/img.jpg';
      return Image.asset(
        path,
        package: isPackageAsset ? 'story_editor' : null,
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(File(path), fit: BoxFit.cover);
    }
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = StoryEditorScope.of(context);
    final state = controller.state;

    return GestureDetector(
      onTap: () {
        controller.deselect();
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // 1. Background Media Layer
            if (state.backgroundPath != null) ...[
              if (state.isVideo &&
                  _videoController != null &&
                  _isVideoInitialized)
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController!.value.size.width,
                      height: _videoController!.value.size.height,
                      child: VideoPlayer(_videoController!),
                    ),
                  ),
                )
              else if (!state.isVideo)
                SizedBox.expand(
                  child: _buildBackgroundImage(state.backgroundPath!),
                ),
            ],
            // 2. Interactive Layers Stack
            ...state.layers.map((layer) {
              return LayerFrame(
                key: ValueKey(layer.id),
                layer: layer,
                child: LayerRenderer.render(
                  layer,
                  registry: widget.pluginRegistry,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
