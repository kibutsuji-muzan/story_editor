import 'package:flutter/material.dart';

class LayerControls extends StatelessWidget {
  final VoidCallback onDelete;
  final VoidCallback onBringToFront;

  const LayerControls({
    super.key,
    required this.onDelete,
    required this.onBringToFront,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
          onPressed: onDelete,
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.flip_to_front_rounded, color: Colors.white),
          onPressed: onBringToFront,
        ),
      ],
    );
  }
}
