import 'package:flutter/widgets.dart';

class TransformData {
  final Matrix4 matrix;

  TransformData({
    Matrix4? matrix,
  }) : matrix = matrix ?? Matrix4.identity();

  factory TransformData.fromList(List<dynamic> list) {
    if (list.length != 16) {
      return TransformData();
    }
    final doubleList = list.map((e) => (e as num).toDouble()).toList();
    return TransformData(matrix: Matrix4.fromList(doubleList));
  }

  List<double> toList() {
    final List<double> storage = List<double>.filled(16, 0.0);
    matrix.copyIntoArray(storage);
    return storage;
  }

  TransformData copyWith({Matrix4? matrix}) {
    return TransformData(matrix: matrix ?? this.matrix.clone());
  }
}
