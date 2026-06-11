import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:story_editor/story_editor.dart';
import '../../core/models/editor_layer.dart';

class LayerFrame extends StatefulWidget {
  final EditorLayer layer;
  final Widget child;

  const LayerFrame({super.key, required this.layer, required this.child});

  @override
  State<LayerFrame> createState() => _LayerFrameState();
}

class _LayerFrameState extends State<LayerFrame> {
  late ValueNotifier<Matrix4> _matrixNotifier;

  @override
  void initState() {
    super.initState();
    _matrixNotifier = ValueNotifier(widget.layer.transform.matrix);
  }

  @override
  void didUpdateWidget(covariant LayerFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.layer.transform.matrix != widget.layer.transform.matrix) {
      _matrixNotifier.value = widget.layer.transform.matrix;
    }
  }

  @override
  void dispose() {
    _matrixNotifier.dispose();
    super.dispose();
  }

  double _getScale(Matrix4 matrix) {
    final storage = matrix.storage;
    return math.sqrt(
      storage[0] * storage[0] +
          storage[1] * storage[1] +
          storage[2] * storage[2],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = StoryEditorScope.of(context, listen: false);
    final isSelected = controller.selectedLayerId == widget.layer.id;

    final gestureDetector = MatrixGestureDetector(
      onMatrixUpdate: (m, tm, sm, rm) {
        final currentMatrix = _matrixNotifier.value;
        final currentScale = _getScale(currentMatrix);
        final deltaScale = _getScale(sm);
        final targetScale = currentScale * deltaScale;

        final minScale = StoryEditorConfig.instance.minScaleFactor;
        final maxScale = StoryEditorConfig.instance.maxScaleFactor;

        final clampedScale = targetScale.clamp(minScale, maxScale);
        final adjustedDeltaScale = currentScale > 0
            ? clampedScale / currentScale
            : 1.0;

        final adjustedSm = Matrix4.identity()..scale(adjustedDeltaScale);

        final updatedMatrix = MatrixGestureDetector.compose(
          currentMatrix,
          tm,
          adjustedSm,
          rm,
        );

        _matrixNotifier.value = updatedMatrix;
        controller.updateLayerTransform(widget.layer.id, updatedMatrix);
      },
      onScaleStart: () {
        controller.selectLayer(widget.layer.id);
      },
      onScaleEnd: () {
        controller.commitTransformHistory();
        controller.deselect();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Colors.blue.withValues(alpha: 0.8)
                : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: widget.child,
      ),
    );

    return AnimatedBuilder(
      animation: _matrixNotifier,
      builder: (context, child) {
        return Transform(transform: _matrixNotifier.value, child: child);
      },
      child: gestureDetector,
    );
  }
}
