import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:jiosaavn/jiosaavn.dart';

final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  JioSaavnClient jiosaavan = JioSaavnClient();
  bool _btn = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          _widget(onDragEnd: () {}, onDragStart: () {}),
          ElevatedButton(
            onPressed: () async {
              var res = await jiosaavan.songs.detailsById(['ishfUzbT']);
              print(res[0].downloadUrl![0].link);
              // print(res.results[0].downloadUrl![0].link);
            },
            child: const Text('Press Me!'),
          )
        ],
      ),
    );
  }
}

class _widget extends StatelessWidget {
  const _widget({
    super.key,
    required this.onDragEnd,
    required this.onDragStart,
  });

  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    return MatrixGestureDetector(
      onMatrixUpdate: (m, tm, sm, rm) {
        notifier.value = m;
      },
      onScaleStart: () {},
      onScaleEnd: () {
        onDragEnd();
      },
      child: AnimatedBuilder(
        animation: notifier,
        builder: (ctx, child) {
          return Transform(
            transform: notifier.value,
            child: Container(
              padding: const EdgeInsets.all(32),
              alignment: const Alignment(0, -0.5),
              child: SvgPicture.asset('assets/sticker.svg'),
            ),
          );
        },
      ),
    );
  }
}
