import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

extension Matrix4Extension on Matrix4 {
  Offset get offset => Offset(storage[12], storage[13]);

  double get scaleX => Vector3(entry(0, 0), entry(1, 0), entry(2, 0)).length;

  double get scaleY => Vector3(entry(0, 1), entry(1, 1), entry(2, 1)).length;

  double get rotation => math.atan2(entry(1, 0), entry(0, 0));

  Matrix4 copyWithScaleAndTranslation({
    required double targetScaleX,
    required double targetScaleY,
    required Offset targetOffset,
  }) {
    final copy = clone();
    final double currentScaleX = scaleX;
    final double currentScaleY = scaleY;

    if (currentScaleX > 0) {
      final factorX = targetScaleX / currentScaleX;
      copy.setEntry(0, 0, copy.entry(0, 0) * factorX);
      copy.setEntry(1, 0, copy.entry(1, 0) * factorX);
      copy.setEntry(2, 0, copy.entry(2, 0) * factorX);
    }
    if (currentScaleY > 0) {
      final factorY = targetScaleY / currentScaleY;
      copy.setEntry(0, 1, copy.entry(0, 1) * factorY);
      copy.setEntry(1, 1, copy.entry(1, 1) * factorY);
      copy.setEntry(2, 1, copy.entry(2, 1) * factorY);
    }

    copy.storage[12] = targetOffset.dx;
    copy.storage[13] = targetOffset.dy;

    return copy;
  }
}
