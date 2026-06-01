import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/models/image_layer.dart';

class ImageLayerWidget extends StatelessWidget {
  final ImageLayer layer;

  const ImageLayerWidget({
    super.key,
    required this.layer,
  });

  @override
  Widget build(BuildContext context) {
    if (layer.path.startsWith('http')) {
      return Image.network(
        layer.path,
        fit: BoxFit.contain,
      );
    } else if (layer.path.startsWith('/') || layer.path.contains('cache')) {
      return Image.file(
        File(layer.path),
        fit: BoxFit.contain,
      );
    } else {
      return Image.asset(
        layer.path,
        fit: BoxFit.contain,
      );
    }
  }
}
