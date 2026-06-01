import 'package:flutter/widgets.dart';

enum StoryAnimationType { none, fade, slide, scale }

class StoryAnimationPreset {
  final StoryAnimationType type;
  final Duration duration;
  final Curve curve;

  const StoryAnimationPreset({
    this.type = StoryAnimationType.none,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });
}
