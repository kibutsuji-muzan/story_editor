import 'package:flutter/widgets.dart';

class RotatableLayer {
  static Matrix4 rotate(Matrix4 matrix, double radians) {
    return matrix.clone()..rotateZ(radians);
  }
}
