import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:story_editor/story_editor.dart';
import '../../../extensions/matrix_extension.dart';
import '../../core/utils/trash_can_metrics.dart';

class LayerFrame extends StatefulWidget {
  final EditorLayer layer;
  final Widget child;

  const LayerFrame({super.key, required this.layer, required this.child});

  @override
  State<LayerFrame> createState() => _LayerFrameState();
}

class _LayerFrameState extends State<LayerFrame> with TickerProviderStateMixin {
  late ValueNotifier<Matrix4> _matrixNotifier;
  Ticker? _ticker;
  Matrix4? _gestureMatrix;
  bool _isSnapped = false;

  /// The gesture offset recorded at the exact moment the widget snapped.
  /// Used to measure how far the user's finger has traveled *since* snapping,
  /// so we can decide when to "snap out" based on real cursor displacement.
  Offset? _snapOriginOffset;

  /// The critical distance (in logical pixels) the user's finger must travel
  /// from the snap origin before the widget is released from the trash zone.
  static const double _snapOutCriticalDistance = 80.0;

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
    _ticker?.dispose();
    super.dispose();
  }

  void animateToOffset(Offset target) {
    _ticker?.stop();
    _ticker = createTicker((elapsed) {
      final current = _matrixNotifier.value.offset;

      final next = Offset.lerp(current, target, 0.15)!;

      _matrixNotifier.value.setTranslationRaw(next.dx, next.dy, 0);

      if ((next - target).distance < 0.5) {
        _matrixNotifier.value.setTranslationRaw(target.dx, target.dy, 0);

        _ticker?.stop();
      }
    });
    _ticker?.start();
  }

  @override
  Widget build(BuildContext context) {
    final controller = StoryEditorScope.of(context, listen: false);
    final gestureDetector = MatrixGestureDetector(
      onMatrixUpdate: (m, tm, sm, rm) {
        _gestureMatrix ??= _matrixNotifier.value.clone();

        // Always compose the full gesture so _gestureMatrix tracks the true
        // position of the user's finger, even while the *visual* matrix is frozen.
        _gestureMatrix = MatrixGestureDetector.compose(
          _gestureMatrix!,
          tm,
          sm,
          rm,
        );

        if (_isSnapped) {
          // ── SNAPPED STATE ──
          // The widget is visually locked on the trash can.
          // We do NOT update _matrixNotifier or the controller here — the
          // matrix stays frozen exactly where it was when we snapped.
          //
          // Instead we track how far the cursor has moved since the snap
          // by comparing the current _gestureMatrix offset to the recorded
          // _snapOriginOffset.  When that distance exceeds the critical
          // threshold, we "snap out" and resume normal dragging.

          final cursorOffset = _gestureMatrix!.offset;
          final cursorTravelDistance =
              (cursorOffset - _snapOriginOffset!).distance;

          if (cursorTravelDistance > _snapOutCriticalDistance) {
            // ── SNAP OUT ──
            // The user has dragged far enough from the snap point.
            // Restore the live gesture matrix so the widget jumps to where
            // the finger actually is, and resume normal transform updates.
            setState(() {
              _isSnapped = false;
              _snapOriginOffset = null;
            });
            _ticker?.stop();
            _matrixNotifier.value = _gestureMatrix!;
            controller.updateLayerTransform(widget.layer.id, _gestureMatrix!);
          }
          // else: still snapped → do nothing (matrix stays frozen)

          debugPrint(
            'Snapped – cursor travel: ${cursorTravelDistance.toStringAsFixed(1)}, '
            'threshold: $_snapOutCriticalDistance',
          );
        } else {
          // ── NORMAL (UN-SNAPPED) STATE ──
          // Forward the composed matrix to the visual layer and controller.
          _ticker?.stop();
          _matrixNotifier.value = _gestureMatrix!;
          controller.updateLayerTransform(widget.layer.id, _gestureMatrix!);

          // Check if the layer has entered the trash zone.
          final viewportSize = TrashCanMetrics.viewportSizeFor(context);
          final trashCenter = TrashCanMetrics.centerOffsetForViewport(
            viewportSize,
          );
          final distance = TrashCanMetrics.distanceToCenter(
            _gestureMatrix!.offset,
            trashCenter,
          );

          if (distance <= 40) {
            // ── SNAP IN ──
            // Record where the cursor was at the moment of snapping so we
            // can later measure how far the finger has traveled since then.
            setState(() {
              _isSnapped = true;
              _snapOriginOffset = _gestureMatrix!.offset;
            });
            animateToOffset(trashCenter);
          }

          debugPrint(
            'Gesture Distance: ${distance.toStringAsFixed(1)}, '
            'Is Snapped: $_isSnapped',
          );
        }
      },
      onScaleStart: () {
        controller.selectLayer(widget.layer.id);
        _ticker?.stop();
        _gestureMatrix = _matrixNotifier.value.clone();
        setState(() {
          _isSnapped = false;
          _snapOriginOffset = null;
        });
      },
      onScaleEnd: () {
        final viewportSize = TrashCanMetrics.viewportSizeFor(context);
        final trashCenter = TrashCanMetrics.centerOffsetForViewport(
          viewportSize,
        );
        final distance = TrashCanMetrics.distanceToCenter(
          _matrixNotifier.value.offset,
          trashCenter,
        );

        if (distance <= 60) {
          controller.removeLayer(widget.layer.id);
        } else {
          controller.commitTransformHistory();
          controller.deselect();
        }
        _gestureMatrix = null;
        setState(() {
          _isSnapped = false;
          _snapOriginOffset = null;
        });
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        scale: _isSnapped ? 0.3 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: widget.child,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _matrixNotifier,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: _matrixNotifier.value,
          child: child,
        );
      },
      child: gestureDetector,
    );
  }
}
