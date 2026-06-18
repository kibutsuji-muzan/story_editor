import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:story_editor/story_editor.dart';
import '../../../extensions/matrix_extension.dart';

class LayerFrame extends StatefulWidget {
  final EditorLayer layer;
  final Widget child;

  const LayerFrame({super.key, required this.layer, required this.child});

  @override
  State<LayerFrame> createState() => _LayerFrameState();
}

class _LayerFrameState extends State<LayerFrame>
    with SingleTickerProviderStateMixin {
  late ValueNotifier<Matrix4> _matrixNotifier;
  Ticker? _ticker;
  Matrix4? _gestureMatrix;
  bool _isSnapped = false;

  /// The gesture offset recorded at the exact moment the widget snapped.
  /// Used to measure how far the user's finger has traveled *since* snapping,
  /// so we can decide when to "snap out" based on real cursor displacement.
  Offset? _snapOriginOffset;

  // ── Lifecycle ──────────────────────────────────────────────────────────

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

  // ── Helpers ────────────────────────────────────────────────────────────

  /// Computes the trash-zone center offset for the current context.
  Offset _trashCenter() {
    final viewportSize = LayerFrameMetrics.viewportSizeFor(context);
    return LayerFrameMetrics.centerOffsetForViewport(context, viewportSize);
  }

  /// Returns the distance from [layerOffset] to the trash-zone center.
  double _distanceToTrash(Offset layerOffset) {
    return LayerFrameMetrics.distanceToCenter(layerOffset, _trashCenter());
  }

  /// Resets snap state to the default un-snapped values.
  void _resetSnapState() {
    setState(() {
      _isSnapped = false;
      _snapOriginOffset = null;
    });
  }

  /// Animates the layer's visual position smoothly toward [target].
  void _animateToOffset(Offset target) {
    _ticker?.stop();
    _ticker = createTicker((elapsed) {
      final current = _matrixNotifier.value.offset;
      final next = Offset.lerp(
        current,
        target,
        LayerFrameMetrics.animationLerpFactor,
      )!;

      _matrixNotifier.value.setTranslationRaw(next.dx, next.dy, 0);

      if ((next - target).distance <
          LayerFrameMetrics.animationSettleThreshold) {
        _matrixNotifier.value.setTranslationRaw(target.dx, target.dy, 0);
        _ticker?.stop();
      }
    });
    _ticker?.start();
  }

  /// Stops any running ticker animation.
  void _stopTicker() => _ticker?.stop();

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final controller = StoryEditorScope.of(context, listen: false);

    final gestureDetector = MatrixGestureDetector(
      onMatrixUpdate: (m, tm, sm, rm) {
        _gestureMatrix ??= _matrixNotifier.value.clone();

        // Always compose the full gesture so _gestureMatrix tracks the true
        // position of the user's finger, even while the *visual* matrix is
        // frozen.
        _gestureMatrix = MatrixGestureDetector.compose(
          _gestureMatrix!,
          tm,
          sm,
          rm,
        );

        if (_isSnapped) {
          _handleSnappedUpdate(controller);
        } else {
          _handleNormalUpdate(controller);
        }
      },
      onScaleStart: () {
        if (_gestureMatrix != null) return;
        controller.selectLayer(widget.layer.id);
        _stopTicker();
        _gestureMatrix = _matrixNotifier.value.clone();
        _resetSnapState();
      },
      onScaleEnd: () {
        final distance = _distanceToTrash(_matrixNotifier.value.offset);

        if (distance <= LayerFrameMetrics.deleteRadius) {
          controller.removeLayer(widget.layer.id);
        } else {
          controller.commitTransformHistory();
          controller.deselect();
        }
        _gestureMatrix = null;
        _resetSnapState();
      },
      child: AnimatedScale(
        duration: LayerFrameMetrics.scaleAnimationDuration,
        scale: _isSnapped ? LayerFrameMetrics.snappedScale : 1.0,
        child: Container(
          padding: const EdgeInsets.all(LayerFrameMetrics.framePadding),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.transparent,
              width: LayerFrameMetrics.frameBorderWidth,
            ),
            borderRadius: BorderRadius.circular(
              LayerFrameMetrics.frameBorderRadius,
            ),
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

  // ── Gesture state handlers ─────────────────────────────────────────────

  /// Handles gesture updates while the layer is snapped to the trash zone.
  /// The visual matrix stays frozen; we only track cursor travel to decide
  /// when to "snap out".
  void _handleSnappedUpdate(StoryEditorController controller) {
    final cursorOffset = _gestureMatrix!.offset;
    final cursorTravel = (cursorOffset - _snapOriginOffset!).distance;

    if (cursorTravel > LayerFrameMetrics.snapOutThreshold) {
      // ── SNAP OUT ──
      // User dragged far enough — restore the live gesture matrix.
      _resetSnapState();
      _stopTicker();
      _matrixNotifier.value = _gestureMatrix!;
      controller.updateLayerTransform(widget.layer.id, _gestureMatrix!);
    }
  }

  /// Handles gesture updates in the normal (un-snapped) dragging state.
  /// Forwards the composed matrix to the visual layer and checks whether
  /// the layer has entered the trash zone.
  void _handleNormalUpdate(StoryEditorController controller) {
    _stopTicker();
    _matrixNotifier.value = _gestureMatrix!;
    controller.updateLayerTransform(widget.layer.id, _gestureMatrix!);

    final trashCenter = _trashCenter();
    final distance = LayerFrameMetrics.distanceToCenter(
      _gestureMatrix!.offset,
      trashCenter,
    );

    if (distance <= LayerFrameMetrics.snapInRadius) {
      // ── SNAP IN ──
      _gestureMatrix!.setTranslationRaw(trashCenter.dx, trashCenter.dy, 0);
      setState(() {
        _isSnapped = true;
        _snapOriginOffset = _gestureMatrix!.offset;
      });
      _animateToOffset(trashCenter);
    }
  }
}
