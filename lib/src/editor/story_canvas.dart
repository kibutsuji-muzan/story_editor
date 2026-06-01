import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../core/controllers/story_editor_controller.dart';
import '../layers/widgets/layer_frame.dart';
import '../layers/renderers/layer_renderer.dart';

class StoryCanvas extends StatefulWidget {
  const StoryCanvas({super.key});

  @override
  State<StoryCanvas> createState() => _StoryCanvasState();
}

class _StoryCanvasState extends State<StoryCanvas> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.watch<StoryEditorController>();
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

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StoryEditorController>();
    final state = controller.state;

    return GestureDetector(
      onTap: () {
        controller.deselect();
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
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
                  child: Image.file(
                    File(state.backgroundPath!),
                    fit: BoxFit.cover,
                  ),
                ),
            ],
            // 2. Interactive Layers Stack
            ...state.layers.map((layer) {
              return LayerFrame(
                key: ValueKey(layer.id),
                layer: layer,
                child: LayerRenderer.render(layer),
              );
            }),
          ],
        ),
      ),
    );
  }
}
