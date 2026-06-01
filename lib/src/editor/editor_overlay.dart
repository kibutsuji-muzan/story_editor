import 'package:flutter/material.dart';

class EditorOverlay extends StatelessWidget {
  final Widget child;
  final bool visible;

  const EditorOverlay({
    super.key,
    required this.child,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox();
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: child,
      ),
    );
  }
}
