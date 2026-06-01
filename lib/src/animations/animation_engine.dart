import 'package:flutter/widgets.dart';
import 'animation_models.dart';
import 'presets/fade_animation.dart';
import 'presets/slide_animation.dart';
import 'presets/scale_animation.dart';

class AnimationEngine extends StatefulWidget {
  final Widget child;
  final StoryAnimationPreset preset;
  final bool animate;

  const AnimationEngine({
    super.key,
    required this.child,
    required this.preset,
    this.animate = true,
  });

  @override
  State<AnimationEngine> createState() => _AnimationEngineState();
}

class _AnimationEngineState extends State<AnimationEngine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.preset.duration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.preset.curve),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.preset.curve),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.preset.curve),
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant AnimationEngine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.preset.type) {
      case StoryAnimationType.fade:
        return FadeAnimation(animation: _fadeAnimation, child: widget.child);
      case StoryAnimationType.slide:
        return SlideAnimation(animation: _slideAnimation, child: widget.child);
      case StoryAnimationType.scale:
        return ScaleAnimation(animation: _scaleAnimation, child: widget.child);
      case StoryAnimationType.none:
        return widget.child;
    }
  }
}
