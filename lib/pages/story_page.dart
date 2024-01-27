import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_edit_story/pages/test_copy.dart';
import 'package:flutter_edit_story/widgets/PollsWidget.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

class StoryPage extends StatefulWidget {
  String image;
  String video;
  List<Map<String, dynamic>> widgets;
  StoryPage({
    super.key,
    required this.image,
    required this.video,
    required this.widgets,
  });

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  late VideoPlayerController _controller;
  late Future<void> _initController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.video);
    _initController = _controller.initialize();
    _controller.setLooping(true);
    _controller.setVolume(0);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      startingOpacity: 0.1,
      direction: DismissiblePageDismissDirection.down,
      onDismissed: () => Navigator.of(context).pop(),
      child: SafeArea(
        child: Scaffold(
          body: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: FutureBuilder(
              future: _initController,
              builder: (context, snapshot) => Stack(
                alignment: Alignment.center,
                children: [
                  Hero(tag: widget.image, child: VideoPlayer(_controller)),
                  GestureDetector(
                    onVerticalDragUpdate: (details) {
                      int sensitivity = 8;
                      if (details.delta.dy < -sensitivity) {
                        Navigator.pushReplacement(context, _createRoute());
                      }
                    },
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            transform: GradientRotation(1.5708),
                            colors: [
                              Color.fromARGB(0, 0, 0, 0),
                              Colors.black38,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  for (var wdgt in widget.widgets) _widget(data: wdgt),
                  Align(
                    alignment: Alignment.topCenter,
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: false,
                      colors: const VideoProgressColors(
                        backgroundColor: Colors.white24,
                        playedColor: Colors.white,
                      ),
                      padding: const EdgeInsets.all(0),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      'assets/swip.gif',
                      width: 100,
                      height: 100,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const TestPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class _widget extends StatefulWidget {
  Map<String, dynamic> data;
  _widget({
    super.key,
    required this.data,
  });

  @override
  State<_widget> createState() => __widgetState();
}

class __widgetState extends State<_widget> {
  late Future<dynamic> _widget;
  final AudioPlayer _controller = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _widget = choose();
  }

  Future<Widget> choose() async {
    switch (widget.data['widget']) {
      case const Key('polls'):
        return const PollsWidget();

      case const Key('music'):
        await _controller.setUrl(widget.data['link']);
        _controller.play();
        return WidgetMusic(
          title: widget.data['title'],
          thumbnail: widget.data['thumbnail'],
          subtitle: widget.data['subtitle'],
        );
      default:
        return const Text('data');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.fromList(widget.data['position']).isZero()
          ? Matrix4.identity()
          : Matrix4.fromList(widget.data['position']),
      child: Container(
        padding: const EdgeInsets.all(32),
        alignment: const Alignment(0, -0.5),
        child: FutureBuilder(
          future: _widget,
          builder: (context, snapshot) => (snapshot.hasData)
              ? snapshot.data!
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
