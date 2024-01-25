import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StoryPage extends StatefulWidget {
  String image;
  StoryPage({super.key, required this.image});

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  late VideoPlayerController _controller;
  late Future<void> _initController;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video.mp4');
    _initController = _controller.initialize();
    _controller.setLooping(true);
    _controller.play();
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
      direction: DismissiblePageDismissDirection.multi,
      onDismissed: () => Navigator.of(context).pop(),
      child: SafeArea(
        child: Hero(
          tag: widget.image,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: FutureBuilder(
              future: _initController,
              builder: (context, snapshot) => Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller),
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
                  Transform(
                    transform: Matrix4.identity(),
                    child: const Icon(
                      Icons.access_alarm,
                      size: 30,
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
