import 'dart:convert';
import 'dart:io';

import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_edit_story/main.dart';
import 'package:flutter_edit_story/pages/test_copy.dart';
import 'package:flutter_edit_story/widgets/PollsWidget.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as p;

class StoryPage extends StatefulWidget {
  String userName;
  int? productId;
  String dir;
  StoryPage({
    super.key,
    required this.userName,
    required this.productId,
    required this.dir,
  });

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  late VideoPlayerController _controller;
  late Future<bool> _initController;
  late List<Map<String, dynamic>> _data = [];
  late String image;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    Directory dir = Directory(widget.dir);
    bool video = false;
    for (var a in dir.listSync(followLinks: false)) {
      switch (p.extension(a.path)) {
        case '.json':
          jsonDecode(await File(a.path).readAsString())['widgets']
              .forEach((elem) => setState(() => _data.add(elem)));

          print('data:$_data');

        case '.mp4':
          _controller = VideoPlayerController.file(File(a.path));
          _initController = _controller.initialize().then((value) => true);
          _controller.setLooping(true);
          _controller.play();
          video = true;
          break;
        case '.jpg':
          setState(() {
            image = a.path;
          });
          _initController = Future(() => false);
          break;
      }
    }
  }

  void callback() async {
    if (image.isEmpty) {
      _controller.setVolume(0);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (image.isEmpty) {
      _controller.dispose();
    }
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
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Hero(
                      tag: widget.userName,
                      child: (snapshot.data == true)
                          ? VideoPlayer(_controller)
                          : Image.file(File(image)),
                    ),
                    (widget.productId != null)
                        ? GestureDetector(
                            onVerticalDragUpdate: (details) {
                              int sensitivity = 8;
                              if (details.delta.dy < -sensitivity) {
                                Navigator.pushReplacement(
                                  context,
                                  _createRoute(widget.productId ?? 0),
                                );
                              }
                            },
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
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
                          )
                        : Container(),
                    for (var wdgt in _data) _widget(data: wdgt, func: callback),
                    // Align(
                    //   alignment: Alignment.topCenter,
                    //   child: VideoProgressIndicator(
                    //     _controller,
                    //     allowScrubbing: false,
                    //     colors: const VideoProgressColors(
                    //       backgroundColor: Colors.white24,
                    //       playedColor: Colors.white,
                    //     ),
                    //     padding: const EdgeInsets.all(0),
                    //   ),
                    // ),
                    (widget.productId != null)
                        ? Align(
                            alignment: Alignment.bottomCenter,
                            child: Image.asset(
                              'assets/swip.gif',
                              width: 100,
                              height: 100,
                              color: Colors.white,
                            ),
                          )
                        : const SizedBox()
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

Route _createRoute(int pid) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => TestPage(pid: pid),
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
  Function func;
  _widget({
    super.key,
    required this.data,
    required this.func,
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
    choose().then((value) => print(value));
  }

  Future<Widget> choose() async {
    if (widget.data['widget'].toString().contains('polls')) {
      return const PollsWidget();
    } else if (widget.data['widget'].toString().contains('gif')) {
      return Image.network(widget.data['link']);
    } else if (widget.data['widget'].toString().contains('sticker')) {
      return Image.network(widget.data['link']);
    } else if (widget.data['widget'].toString().contains('music')) {
      await _controller.setUrl(widget.data['link']);
      _controller.setClip(
        start: Duration(milliseconds: widget.data['trim']['start']),
        end: Duration(milliseconds: widget.data['trim']['end']),
      );
      _controller.setLoopMode(LoopMode.one);
      _controller.play();
      widget.func();
      return WidgetMusic(
        title: widget.data['title'],
        thumbnail: widget.data['thumbnail'],
        subtitle: widget.data['subtitle'],
      );
    } else if (widget.data['widget'].toString().contains('text')) {
      return Text(
        widget.data['data'],
        style: TextStyle(
          fontFamily: widget.data['font'],
          fontSize: 50,
          color: widget.data['color'].toString().hextocolor,
        ),
      );
    } else {
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
      transform:
          Matrix4.fromList(widget.data['position'].cast<double>()).isZero()
              ? Matrix4.identity()
              : Matrix4.fromList(widget.data['position'].cast<double>()),
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
