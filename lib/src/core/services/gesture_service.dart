import 'package:flutter/widgets.dart';

class GestureService {
  static Matrix4 scaleAndTranslate(Matrix4 base, Matrix4 update) {
    return base * update;
  }
}
