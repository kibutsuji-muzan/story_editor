import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/models/sticker_layer.dart';

class StickerLayerWidget extends StatelessWidget {
  final StickerLayer layer;

  const StickerLayerWidget({
    super.key,
    required this.layer,
  });

  @override
  Widget build(BuildContext context) {
    if (layer.url.endsWith('.svg')) {
      return SvgPicture.asset(
        layer.url,
        width: 120,
        height: 120,
      );
    } else {
      return Image.network(
        layer.url,
        fit: BoxFit.contain,
        width: 150,
        height: 150,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.broken_image,
          color: Colors.white,
          size: 40,
        ),
      );
    }
  }
}
