import 'package:flutter/widgets.dart';

class ScalableLayer {
  static Matrix4 scale(Matrix4 matrix, double scaleFactor) {
    // ignore: deprecated_member_use
    return matrix.clone()..scale(scaleFactor);
  }
}
