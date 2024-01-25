import 'package:flutter/material.dart';
import 'package:flutter_edit_story/var.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:provider/provider.dart';

typedef PointMoveCallback = void Function(Offset offset, Key? key);

class WidgetItem extends StatefulWidget {
  final Widget widget;
  Key key;
  WidgetItem({
    required this.key,
    required this.widget,
    required this.onDragEnd,
    required this.onDragStart,
    required this.onDragUpdate,
  });
  final VoidCallback onDragStart;
  final PointMoveCallback onDragEnd;
  final PointMoveCallback onDragUpdate;

  @override
  State<WidgetItem> createState() => _WidgetItemState();
}

class _WidgetItemState extends State<WidgetItem> {
  final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
  late Offset offset;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: (event) {
        setState(() {
          offset = event.position;
        });
        widget.onDragUpdate(offset, widget.key);
      },
      child: MatrixGestureDetector(
        onMatrixUpdate: (m, tm, sm, rm) {
          //should save m in provider for positioning in sttory
          notifier.value = m;
          Provider.of<ActiveWidget>(context, listen: false)
              .updatePosition(key: widget.key, matrix: m);
        },
        onScaleStart: () {
          widget.onDragStart();
        },
        onScaleEnd: () {
          widget.onDragEnd(offset, widget.key);
        },
        child: AnimatedBuilder(
          animation: notifier,
          builder: (ctx, child) {
            return Transform(
              transform: notifier.value,
              child: Container(
                padding: const EdgeInsets.all(32),
                alignment: const Alignment(0, -0.5),
                child: widget.widget,
              ),
            );
          },
        ),
      ),
    );
  }
}
