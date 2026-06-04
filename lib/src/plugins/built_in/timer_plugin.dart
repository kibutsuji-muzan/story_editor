import 'package:flutter/material.dart';

import '../../core/controllers/story_editor_controller.dart';
import '../../core/models/editor_layer.dart';
import '../../core/utils/layer_utils.dart';
import '../../features/timer/timer_layer.dart';
import '../editor_plugin.dart';

class TimerPlugin extends EditorPlugin {
  const TimerPlugin()
    : super(id: 'timer', name: 'Timer', icon: Icons.timer_rounded);

  @override
  Set<LayerType> get supportedLayerTypes => const {LayerType.timer};

  @override
  Set<String> get supportedWidgetTypes => const {'timer'};

  @override
  EditorLayer createLayer() => TimerLayer(id: '', duration: '00:00:10');

  @override
  Widget buildLayer(BuildContext context, EditorLayer layer) {
    return _TimerLayerView(layer: layer as TimerLayer);
  }

  @override
  Map<String, dynamic> toJson(EditorLayer layer) {
    return (layer as TimerLayer).toJson();
  }

  @override
  EditorLayer fromJson(Map<String, dynamic> json) {
    return TimerLayer.fromJson(json);
  }

  @override
  Future<void> onTap(
    BuildContext context,
    StoryEditorController controller,
  ) async {
    final durationController = TextEditingController(text: '00:00:10');
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add timer'),
          content: TextField(
            controller: durationController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'HH:MM:SS'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(durationController.text);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    durationController.dispose();

    if (result == null || result.trim().isEmpty) return;

    controller.addLayer(
      TimerLayer(
        id: LayerUtils.generateUniqueId('timer'),
        duration: result.trim(),
      ),
    );
  }
}

class _TimerLayerView extends StatelessWidget {
  final TimerLayer layer;

  const _TimerLayerView({required this.layer});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: Stream.periodic(const Duration(seconds: 1), (tick) => tick),
      builder: (context, snapshot) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              _remainingLabel(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        );
      },
    );
  }

  String _remainingLabel() {
    final createdAt = DateTime.tryParse(layer.createdAt);
    final duration = _parseDuration(layer.duration);
    if (createdAt == null || duration == Duration.zero) {
      return layer.duration;
    }

    final remaining = createdAt.add(duration).difference(DateTime.now());
    if (remaining.isNegative) return '00:00:00';
    return _formatDuration(remaining);
  }

  Duration _parseDuration(String value) {
    final parts = value.split(':').map((part) => int.tryParse(part)).toList();
    if (parts.length == 3 && parts.every((part) => part != null)) {
      return Duration(hours: parts[0]!, minutes: parts[1]!, seconds: parts[2]!);
    }

    final seconds = int.tryParse(value);
    if (seconds != null) return Duration(seconds: seconds);

    return Duration.zero;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }
}
