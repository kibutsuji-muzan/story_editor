import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:video_player/video_player.dart';

enum _grp { Yes, No }

List<Widget> _allWidgetsList = [
  _PollsWidget(),
  SvgPicture.asset(
    'assets/sticker.svg',
    width: 100,
  ),
];

class VideoEditPage extends StatefulWidget {
  const VideoEditPage({super.key});

  @override
  State<StatefulWidget> createState() => _VideoEditPageState();
}

class _VideoEditPageState extends State<VideoEditPage> {
  late VideoPlayerController _controller;
  late Future<void> _initController;
  bool _audio = true;

  List<Widget> _localactivelist = [];

  void refresh(Widget item) {
    setState(() {
      _localactivelist.add(item);
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video.mp4');
    _initController = _controller.initialize().then((_) => _controller.play());
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
                        isScrollControlled: true,
                        builder: (context) {
                          return _scrollModal(notifyParent: refresh);
                        },
                      ),
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
          for (Widget elem in _localactivelist)
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

class _scrollModal extends StatefulWidget {
  Function notifyParent;
  _scrollModal({super.key, required this.notifyParent});

  @override
  State<StatefulWidget> createState() => _scrollModalState();
}

class _scrollModalState extends State<_scrollModal> {
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
                itemCount: _allWidgetsList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      widget.notifyParent(_allWidgetsList[index]);
                      Navigator.of(context).pop(context);
                    },
                    child: GridTile(
                      child: Center(
                        child: _allWidgetsList[index],
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
