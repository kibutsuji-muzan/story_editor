import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

extension Matrix4Extension on Matrix4 {
  Offset get offset => Offset(storage[12], storage[13]);

  double get scaleX => Vector3(entry(0, 0), entry(1, 0), entry(2, 0)).length;

  double get scaleY => Vector3(entry(0, 1), entry(1, 1), entry(2, 1)).length;

  double get rotation => math.atan2(entry(1, 0), entry(0, 0));
}
