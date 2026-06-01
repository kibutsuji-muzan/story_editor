import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:provider/provider.dart';
import '../../core/controllers/story_editor_controller.dart';
import '../../core/models/editor_layer.dart';

class LayerFrame extends StatefulWidget {
  final EditorLayer layer;
  final Widget child;

  const LayerFrame({
    super.key,
    required this.layer,
    required this.child,
  });

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

  @override
  Widget build(BuildContext context) {
    final controller = context.read<StoryEditorController>();
    final isSelected = controller.selectedLayerId == widget.layer.id;

    return MatrixGestureDetector(
      onMatrixUpdate: (m, tm, sm, rm) {
        final updatedMatrix = MatrixGestureDetector.compose(
          _matrixNotifier.value,
          tm,
          sm,
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
      },
      child: AnimatedBuilder(
        animation: _matrixNotifier,
        builder: (context, child) {
          return Transform(
            transform: _matrixNotifier.value,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () {
                    controller.selectLayer(widget.layer.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.blue.withValues(alpha: 0.8) : Colors.transparent,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: widget.child,
                  ),
                ),
                if (isSelected) ...[
                  // Quick delete button on top-right of the frame
                  Positioned(
                    top: -12,
                    right: -12,
                    child: GestureDetector(
                      onTap: () {
                        controller.removeLayer(widget.layer.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
