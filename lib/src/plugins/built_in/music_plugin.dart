import 'package:flutter/material.dart';

import '../../core/controllers/story_editor_controller.dart';
import '../../core/models/editor_layer.dart';
import '../../features/music/music_layer.dart';
import '../editor_plugin.dart';

class MusicPlugin extends EditorPlugin {
  const MusicPlugin()
    : super(id: 'music', name: 'Music', icon: Icons.music_note_rounded);

  @override
  Set<LayerType> get supportedLayerTypes => const {LayerType.music};

  @override
  Set<String> get supportedWidgetTypes => const {'music', 'song'};

  @override
  EditorLayer createLayer() {
    return MusicLayer(
      id: '',
      url: '',
      title: 'Music',
      thumbnail: '',
      subtitle: '',
    );
  }

  @override
  Widget buildLayer(BuildContext context, EditorLayer layer) {
    final music = layer as MusicLayer;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MusicArtwork(thumbnail: music.thumbnail),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  music.title.isEmpty ? 'Music' : music.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
                if (music.subtitle.isNotEmpty)
                  Text(
                    music.subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 11,
                      decoration: TextDecoration.none,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson(EditorLayer layer) {
    return (layer as MusicLayer).toJson();
  }

  @override
  EditorLayer fromJson(Map<String, dynamic> json) {
    return MusicLayer.fromJson(json);
  }

  @override
  Future<void> onTap(
    BuildContext context,
    StoryEditorController controller,
  ) async {}
}

class _MusicArtwork extends StatelessWidget {
  final String thumbnail;

  const _MusicArtwork({required this.thumbnail});

  @override
  Widget build(BuildContext context) {
    if (thumbnail.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          thumbnail,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const _MusicIcon(),
        ),
      );
    }

    return const _MusicIcon();
  }
}

class _MusicIcon extends StatelessWidget {
  const _MusicIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 36,
      height: 36,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Icon(Icons.music_note_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}
