import 'package:flutter/widgets.dart';

class MatrixUtils {
  static List<double> matrixToList(Matrix4 matrix) {
    final List<double> list = List<double>.filled(16, 0.0);
    matrix.copyIntoArray(list);
    return list;
  }

  static Matrix4 listToMatrix(List<dynamic> list) {
    if (list.length != 16) return Matrix4.identity();
    final doubleList = list.map((e) => (e as num).toDouble()).toList();
    return Matrix4.fromList(doubleList);
  }
}
