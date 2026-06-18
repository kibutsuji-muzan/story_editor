import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:story_editor/story_editor.dart';

class StoryCanvas extends StatefulWidget {
  final PluginRegistry? pluginRegistry;

  const StoryCanvas({super.key, this.pluginRegistry});

  @override
  State<StoryCanvas> createState() => _StoryCanvasState();
}

class _StoryCanvasState extends State<StoryCanvas> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  MediaSource? _currentSource;
  File? _tempVideoFile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = StoryEditorScope.of(context);
    final state = controller.state;
    final source = state.background;

    if (source != null && source.type == MediaType.video) {
      if (_videoController == null || !_isSameSource(_currentSource, source)) {
        _disposeVideo();
        _currentSource = source;
        _initializeVideo(source);
      }
    } else {
      _disposeVideo();
      _currentSource = null;
    }
  }

  bool _isSameSource(MediaSource? a, MediaSource? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.runtimeType != b.runtimeType) return false;

    if (a is FileMediaSource && b is FileMediaSource) {
      return a.file.path == b.file.path;
    }
    if (a is MemoryMediaSource && b is MemoryMediaSource) {
      return identical(a.bytes, b.bytes);
    }
    if (a is NetworkMediaSource && b is NetworkMediaSource) {
      return a.url == b.url;
    }
    if (a is AssetMediaSource && b is AssetMediaSource) {
      return a.path == b.path;
    }
    return false;
  }

  void _initializeVideo(MediaSource source) async {
    VideoPlayerController? controller;

    if (source is FileMediaSource) {
      controller = VideoPlayerController.file(source.file);
    } else if (source is NetworkMediaSource) {
      controller = VideoPlayerController.networkUrl(Uri.parse(source.url));
    } else if (source is AssetMediaSource) {
      final isPackageAsset = source.path == 'assets/img.jpg';
      controller = VideoPlayerController.asset(
        source.path,
        package: isPackageAsset ? 'story_editor' : null,
      );
    } else if (source is MemoryMediaSource) {
      try {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
          '${tempDir.path}/temp_video_${DateTime.now().microsecondsSinceEpoch}.mp4',
        );
        await tempFile.writeAsBytes(source.bytes);
        _tempVideoFile = tempFile;
        controller = VideoPlayerController.file(tempFile);
      } catch (e) {
        debugPrint('Error writing memory video to temp file: $e');
        return;
      }
    }

    if (controller == null) return;

    if (!mounted || _currentSource != source) {
      controller.dispose();
      return;
    }

    _videoController = controller;

    try {
      await controller.initialize();
      if (mounted && _videoController == controller) {
        setState(() {
          _isVideoInitialized = true;
        });
        await controller.setLooping(true);
        await controller.play();
      } else {
        controller.dispose();
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  void _disposeVideo() {
    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;
    _isVideoInitialized = false;

    final tempFile = _tempVideoFile;
    if (tempFile != null) {
      _tempVideoFile = null;
      tempFile.exists().then((exists) {
        if (exists) {
          tempFile.delete().catchError((e) {
            debugPrint('Failed to delete temp video file: $e');
          });
        }
      });
    }
  }

  Widget _buildBackgroundImage(MediaSource source) {
    if (source is NetworkMediaSource) {
      return Image.network(source.url, fit: BoxFit.cover);
    } else if (source is AssetMediaSource) {
      return Image.asset(source.path, fit: BoxFit.cover);
    } else if (source is FileMediaSource) {
      return Image.file(source.file, fit: BoxFit.cover);
    } else if (source is MemoryMediaSource) {
      return Image.memory(source.bytes, fit: BoxFit.cover);
    } else {
      return const SizedBox.shrink();
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
            if (state.background != null) ...[
              if (state.background!.type == MediaType.video &&
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
              else if (state.background!.type == MediaType.image)
                SizedBox.expand(
                  child: _buildBackgroundImage(state.background!),
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
