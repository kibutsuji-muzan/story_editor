import 'package:flutter/material.dart';
import 'package:story_editor/story_editor.dart';

/// Single source of truth for every metric, threshold, and geometry helper
/// shared between [LayerFrame] and the trash-can widget.
///
/// Organised into logical sections:
///   • Layer-frame visuals & animation
///   • Snap / delete behaviour
///   • Trash-can widget visuals (responsive)
///   • Viewport & geometry helpers
class LayerFrameMetrics {
  const LayerFrameMetrics._();

  // ═══════════════════════════════════════════════════════════════════════
  // LAYER-FRAME VISUALS
  // ═══════════════════════════════════════════════════════════════════════

  /// Padding around the child widget inside the layer frame.
  static const double framePadding = 12.0;

  /// Border width of the transparent frame border.
  static const double frameBorderWidth = 1.5;

  /// Corner radius of the layer frame.
  static const double frameBorderRadius = 8.0;

  // ═══════════════════════════════════════════════════════════════════════
  // SNAP & DELETE BEHAVIOUR
  // ═══════════════════════════════════════════════════════════════════════

  /// Distance the finger must travel from the snap origin to release
  /// ("snap out").
  static const double snapOutThreshold = 40.0;

  /// Max distance from trash center to trigger a snap-in.
  static const double snapInRadius = 40.0;

  /// Max distance from trash center to confirm deletion on gesture end.
  static const double deleteRadius = 60.0;

  /// Distance threshold to show the "active / hovered" state on the
  /// trash-can icon.
  static const double trashActivationRadius = 60.0;

  /// Scale reduction when the layer magnets to the trash can.
  static const double magnetScaleReduction = 0.75;

  // ═══════════════════════════════════════════════════════════════════════
  // SNAP ANIMATION TUNING
  // ═══════════════════════════════════════════════════════════════════════

  /// Scale factor when the layer is snapped to the trash zone.
  static const double snappedScale = 0.3;

  /// Lerp factor per tick for the smooth snap animation.
  static const double animationLerpFactor = 0.15;

  /// Minimum remaining distance to consider the animation complete.
  static const double animationSettleThreshold = 0.5;

  /// Duration of the scale animation when snapping / un-snapping.
  static const Duration scaleAnimationDuration = Duration(milliseconds: 300);

  // ═══════════════════════════════════════════════════════════════════════
  // TRASH-CAN WIDGET VISUALS (responsive)
  // ═══════════════════════════════════════════════════════════════════════
  // Base values are designed for a ~375-pt-wide screen.  The responsive
  // accessors scale them up to 1.4× on wider devices.

  static const double _baseTrashMargin = 10.0;
  static const double _baseTrashPadding = 6.0;
  static const double _baseTrashBorderWidth = 2.0;
  static const double _baseTrashIconSize = 35.0;
  static const double _baseTrashBorderRadius = 100.0;

  /// Reference screen width the base values were designed for.
  static const double _referenceWidth = 375.0;

  /// Returns a multiplier ≥ 1.0 that scales base values for wider screens.
  static double _scaleFactor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (width / _referenceWidth).clamp(1.0, 1.4);
  }

  static double trashMargin(BuildContext context) =>
      _baseTrashMargin * _scaleFactor(context);

  static double trashPadding(BuildContext context) =>
      _baseTrashPadding * _scaleFactor(context);

  static double trashBorderWidth(BuildContext context) =>
      _baseTrashBorderWidth * _scaleFactor(context);

  static double trashIconSize(BuildContext context) =>
      _baseTrashIconSize * _scaleFactor(context);

  static double trashBorderRadius(BuildContext context) =>
      _baseTrashBorderRadius * _scaleFactor(context);

  // ═══════════════════════════════════════════════════════════════════════
  // DERIVED LAYOUT
  // ═══════════════════════════════════════════════════════════════════════

  /// Vertical distance from the bottom of the viewport to the trash-can's
  /// visual center.  Used by the geometry helpers to position the snap
  /// target correctly.
  static double trashCenterDistanceFromBottom(BuildContext context) {
    return trashMargin(context) +
        trashBorderWidth(context) +
        trashPadding(context) +
        trashIconSize(context) / 2 +
        5;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // VIEWPORT & GEOMETRY HELPERS
  // ═══════════════════════════════════════════════════════════════════════

  /// Returns the usable viewport [Size] for trash-zone geometry, excluding
  /// safe-area insets and the trash-can's own height offset.
  static Size viewportSizeFor(
    BuildContext context, {
    BoxConstraints? constraints,
  }) {
    final mediaPadding = MediaQuery.paddingOf(context);
    final bottomOffset = trashCenterDistanceFromBottom(context);

    constraints ??= BoxConstraints(
      maxHeight:
          context.screenHeight - mediaPadding.vertical - bottomOffset,
      maxWidth: context.screenWidth - mediaPadding.horizontal,
    );

    if (constraints.hasBoundedWidth && constraints.hasBoundedHeight) {
      return constraints.biggest;
    }

    final mediaSize = MediaQuery.sizeOf(context);
    return Size(
      mediaSize.width - mediaPadding.horizontal,
      mediaSize.height - mediaPadding.vertical,
    );
  }

  /// Returns the center [Offset] of the trash zone within the viewport.
  static Offset centerOffsetForViewport(
    BuildContext context,
    Size viewportSize,
  ) {
    final bottomOffset = trashCenterDistanceFromBottom(context);
    return Offset(0, viewportSize.height / 2 - bottomOffset);
  }

  /// Euclidean distance between [layerOffset] and [trashCenter].
  static double distanceToCenter(Offset layerOffset, Offset trashCenter) {
    return (layerOffset - trashCenter).distance;
  }

  /// Magnet strength curve (0 → 1) based on distance to trash center.
  static double magnetStrength(double distance) {
    if (distance >= trashActivationRadius) return 0.0;

    final linearStrength = 1.0 - distance / trashActivationRadius;
    return Curves.easeOutCubic.transform(linearStrength.clamp(0.0, 1.0));
  }
}
