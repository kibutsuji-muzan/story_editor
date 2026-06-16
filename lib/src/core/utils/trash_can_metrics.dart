import 'package:flutter/material.dart';
import 'package:story_editor/story_editor.dart';

class TrashCanMetrics {
  static const double activationRadius = 60.0;
  static const double magnetScaleReduction = 0.75;

  static const double margin = 10.0;
  static const double padding = 6.0;
  static const double borderWidth = 2.0;
  static const double iconSize = 35.0;

  static const double centerDistanceFromBottom =
      margin + borderWidth + padding + iconSize / 2 + 5;

  static Size viewportSizeFor(
    BuildContext context, {
    BoxConstraints? constraints,
  }) {
    constraints ??= BoxConstraints(
      maxHeight:
          context.screenHeight -
          MediaQuery.paddingOf(context).vertical -
          centerDistanceFromBottom,
      maxWidth: context.screenWidth - MediaQuery.paddingOf(context).horizontal,
    );
    if (constraints.hasBoundedWidth && constraints.hasBoundedHeight) {
      return constraints.biggest;
    }

    final mediaPadding = MediaQuery.paddingOf(context);
    final mediaSize = MediaQuery.sizeOf(context);
    return Size(
      mediaSize.width - mediaPadding.horizontal,
      mediaSize.height - mediaPadding.vertical,
    );
  }

  static Offset centerOffsetForViewport(Size viewportSize) {
    return Offset(0, viewportSize.height / 2 - centerDistanceFromBottom);
  }

  static double distanceToCenter(Offset layerOffset, Offset trashCenter) {
    return (layerOffset - trashCenter).distance;
  }

  static double magnetStrength(double distance) {
    if (distance >= activationRadius) return 0.0;

    final linearStrength = 1.0 - distance / activationRadius;
    return Curves.easeOutCubic.transform(linearStrength.clamp(0.0, 1.0));
  }
}
