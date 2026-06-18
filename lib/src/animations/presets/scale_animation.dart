import 'package:flutter/widgets.dart';

class ScaleAnimation extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const ScaleAnimation({
    super.key,
    required this.child,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: child,
    );
  }
}
