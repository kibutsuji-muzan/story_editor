import 'package:flutter/widgets.dart';

class DraggableLayer {
  static Matrix4 translate(Matrix4 matrix, Offset translation) {
    // ignore: deprecated_member_use
    return matrix.clone()..translate(translation.dx, translation.dy);
  }
}
