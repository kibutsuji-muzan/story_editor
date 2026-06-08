import 'package:flutter/material.dart';

import '../../core/controllers/story_editor_controller.dart';
import '../../core/models/editor_layer.dart';
import '../../core/utils/layer_utils.dart';
import 'polls_layer.dart';
import '../../plugins/editor_plugin.dart';

class PollsPlugin extends EditorPlugin {
  const PollsPlugin()
    : super(id: 'polls', name: 'Poll', icon: Icons.poll_rounded);

  @override
  Set<LayerType> get supportedLayerTypes => const {LayerType.polls};

  @override
  Set<String> get supportedWidgetTypes => const {'polls', 'poll'};

  @override
  EditorLayer createLayer() => PollsLayer(id: '');

  @override
  Widget buildLayer(BuildContext context, EditorLayer layer) {
    final poll = layer as PollsLayer;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              poll.question,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PollOption(label: poll.option1),
                const SizedBox(width: 8),
                _PollOption(label: poll.option2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson(EditorLayer layer) {
    return (layer as PollsLayer).toJson();
  }

  @override
  EditorLayer fromJson(Map<String, dynamic> json) {
    return PollsLayer.fromJson(json);
  }

  @override
  Future<void> onTap(
    BuildContext context,
    StoryEditorController controller,
  ) async {
    controller.addLayer(PollsLayer(id: LayerUtils.generateUniqueId('polls')));
  }
}

class _PollOption extends StatelessWidget {
  final String label;

  const _PollOption({required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
