import 'package:flutter/material.dart';

class StoryEditorOverlay extends StatefulWidget {
  final Widget child;

  const StoryEditorOverlay({super.key, required this.child});

  @override
  State<StoryEditorOverlay> createState() => _StoryEditorOverlayState();
}

class _StoryEditorOverlayState extends State<StoryEditorOverlay> {
  double drag = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          drag += details.delta.dy;
        });
      },
      onVerticalDragEnd: (details) {
        if (drag > 150) {
          Navigator.pop(context);
        } else {
          setState(() {
            drag = 0;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, drag, 0),
        child: widget.child,
      ),
    );
  }
}
