import 'package:flutter/material.dart';
import '../../core/models/text_layer.dart';

class TextLayerWidget extends StatelessWidget {
  final TextLayer layer;

  const TextLayerWidget({
    super.key,
    required this.layer,
  });

  @override
  Widget build(BuildContext context) {
    // Parse color safely
    Color textColor = Colors.white;
    try {
      final hex = layer.colorHex.replaceAll('#', '');
      textColor = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {}

    return Text(
      layer.text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: layer.fontFamily,
        color: textColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.none,
      ),
    );
  }
}
