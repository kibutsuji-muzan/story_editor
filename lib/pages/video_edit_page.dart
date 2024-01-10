import 'package:flutter/material.dart';
import 'package:flutter_edit_story/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum _grp { Yes, No }

final allwidgetsProvider = StateProvider<List<Widget>>(
  (ref) => [
    const _PollsWidget(),
    SvgPicture.asset('assets/sticker.svg', width: 100),
  ],
);
// List<Widget> _widgets = [
//   const _PollsWidget(),
//   SvgPicture.asset('assets/sticker.svg', width: 100),
// ];

class VideoEditPage extends ConsumerStatefulWidget {
  const VideoEditPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VideoEditPageState();
}

class _VideoEditPageState extends ConsumerState<VideoEditPage> {
  late VideoPlayerController _controller;
  late Future<void> _initController;
  bool _audio = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video.mp4');
    // _initController = _controller.initialize().then((_) => _controller.play());
    _initController =
        _controller.initialize().then((_) => _controller.setLooping(true));
    // _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      activewidgetsProvider,
      (previous, next) => (print('update')),
    );
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
            future: _initController,
            builder: (context, snapshot) {
              return VideoPlayer(_controller);
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _audio = !_audio;
                        });
                        _audio
                            ? _controller.setVolume(100)
                            : _controller.setVolume(0.0);
                      },
                      splashColor: Colors.white,
                      icon: Icon(
                        (_audio)
                            ? Icons.music_note_rounded
                            : Icons.music_off_rounded,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showBottomModal(context),
                      splashColor: Colors.white,
                      icon: const Icon(
                        Icons.emoji_symbols_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          for (Widget elem in ref.watch(activewidgetsProvider))
            _widget(
              widget: elem,
            ),
        ],
      ),
    );
  }
}

class _widget extends StatelessWidget {
  final Widget widget;
  const _widget({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
    return MatrixGestureDetector(
      onMatrixUpdate: (m, tm, sm, rm) {
        notifier.value = m;
      },
      child: AnimatedBuilder(
        animation: notifier,
        builder: (ctx, child) {
          return Transform(
            transform: notifier.value,
            child: Container(
              padding: const EdgeInsets.all(32),
              alignment: const Alignment(0, -0.5),
              child: widget,
            ),
          );
        },
      ),
    );
  }
}

class _PollsWidget extends StatefulWidget {
  const _PollsWidget({super.key});

  @override
  State<_PollsWidget> createState() => __PollsWidgetState();
}

class __PollsWidgetState extends State<_PollsWidget> {
  _grp? _radiovalue;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: const Alignment(0, -0.5),
      width: MediaQuery.of(context).size.width * 0.6,
      height: MediaQuery.of(context).size.height * 0.15,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Text(
              'Some Text Here',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 43, 43, 43),
              ),
            ),
          ),
          Row(
            children: [
              Radio(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: _grp.Yes,
                groupValue: _radiovalue,
                onChanged: (value) {
                  setState(() {
                    _radiovalue = value;
                  });
                },
              ),
              const Text(
                '10% ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: LinearProgressIndicator(
                    color: Colors.green,
                    minHeight: 12,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    value: 0.1,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Radio(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: _grp.No,
                groupValue: _radiovalue,
                onChanged: (value) {
                  setState(() {
                    _radiovalue = value;
                  });
                },
              ),
              const Text(
                '10% ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: LinearProgressIndicator(
                    color: Colors.red,
                    minHeight: 12,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    value: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future _showBottomModal(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
    isScrollControlled: true,
    builder: (context) {
      return ProviderScope(child: _scrollModal());
    },
  );
}

class _scrollModal extends ConsumerStatefulWidget {
  const _scrollModal({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _scrollModalState();
}

class _scrollModalState extends ConsumerState<_scrollModal> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 0.9,
      minChildSize: 0.1,
      initialChildSize: 0.2,
      builder: (context, scrollController) {
        return Container(
          margin: const EdgeInsets.only(top: 50),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadiusDirectional.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  width: 30,
                  height: 10,
                  margin: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.01,
                    horizontal: MediaQuery.of(context).size.width * 0.4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SliverGrid.builder(
                itemCount: ref.watch(allwidgetsProvider).length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(activewidgetsProvider.notifier)
                          .state
                          .add(ref.watch(allwidgetsProvider)[index]);

                      print(ref.watch(activewidgetsProvider));
                    },
                    child: GridTile(
                      child: Center(
                        child: ref.read(allwidgetsProvider)[index],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
