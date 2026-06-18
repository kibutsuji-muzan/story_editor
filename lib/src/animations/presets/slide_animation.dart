import 'package:flutter/widgets.dart';

class SlideAnimation extends StatelessWidget {
  final Widget child;
  final Animation<Offset> animation;

  const SlideAnimation({
    super.key,
    required this.child,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: animation,
      child: child,
    );
  }
}
