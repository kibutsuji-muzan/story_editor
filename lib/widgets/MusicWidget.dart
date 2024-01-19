import 'dart:io';
import 'dart:math';

import 'package:flutter_edit_story/var.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:easy_audio_trimmer/easy_audio_trimmer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class MusicWidget extends StatefulWidget {
  String url;
  String title;
  String thumbnail;
  String subtitle;

  MusicWidget({
    super.key,
    required this.url,
    required this.title,
    required this.thumbnail,
    required this.subtitle,
  });

  @override
  State<MusicWidget> createState() => _MusicWidgetState();
}

class _MusicWidgetState extends State<MusicWidget>
    with TickerProviderStateMixin {
  final String gifAsset = 'assets/music.gif';
  final AudioPlayer _player = AudioPlayer();
  double _start = 0;
  double _end = 0;

  @override
  void initState() {
    super.initState();
    _player.setUrl(widget.url);
    // _player.setLoopMode(LoopMode.one);
    setState(() {
      _end = Provider.of<VideoDurationModel>(context, listen: false)
          .durationInMilliSeconds
          .toDouble();
    });
    _player.setClip(
      start: Duration(milliseconds: _start.toInt()),
      end: Duration(
        milliseconds: _end.toInt(),
      ),
    );
    _player.play();
  }

  void _setClip({required double start, required double end}) {
    print('called');
    final AudioPlayer player = AudioPlayer();
    setState(() {
      _start = start;
      _end = end;
    });
    player.setUrl(widget.url);
    player.setClip(
      start: Duration(milliseconds: _start.toInt()),
      end: Duration(
        milliseconds: _end.toInt(),
      ),
    );
    player.play();
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _player.stop();
        context.pushTransparentRoute(
          _TrimmingPage(
            url: widget.url,
            title: widget.title,
            thumbnail: widget.thumbnail,
            subtitle: widget.subtitle,
            setClip: _setClip,
          ),
        );
      },
      behavior: HitTestBehavior.translucent,
      child: Hero(
        tag: widget.title,
        child: _WidgetMusic(
          title: widget.title,
          thumbnail: widget.thumbnail,
          subtitle: widget.subtitle,
        ),
      ),
    );
  }
}

class _TrimmingPage extends StatefulWidget {
  String url;
  String title;
  String thumbnail;
  String subtitle;
  Function setClip;
  _TrimmingPage({
    super.key,
    required this.url,
    required this.title,
    required this.thumbnail,
    required this.subtitle,
    required this.setClip,
  });

  @override
  State<_TrimmingPage> createState() => _TrimmingPageState();
}

class _TrimmingPageState extends State<_TrimmingPage> {
  double _startValue = 0.0;
  double _endValue = 0.0;

  final Trimmer _trimmer = Trimmer();
  late File _file;
  bool _isPlaying = true;
  bool _progressVisibility = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadAndSaveFile();
  }

  String randomHexString(int length) {
    Random _random = Random();
    StringBuffer sb = StringBuffer();
    for (var i = 0; i < length; i++) {
      sb.write(_random.nextInt(16).toRadixString(16));
    }
    return sb.toString();
  }

  Future<void> loadAndSaveFile() async {
    var res = await http.get(
      Uri.parse(widget.url),
    );
    Directory tempDir = await getTemporaryDirectory();
    String filename = '${tempDir.path}/audio.mp4';
    File file = File(filename);
    await file.writeAsBytes(res.bodyBytes);
    setState(() {
      _file = file;
    });
    _loadAudio();
  }

  void _loadAudio() async {
    setState(() {
      isLoading = true;
    });

    await _trimmer.loadAudio(audioFile: _file).then((value) => _trimmerplay());

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _trimmerplay() async {
    bool _playback = await _trimmer.audioPlaybackControl(
        startValue: _startValue, endValue: _endValue);
    setState(() {
      _isPlaying = _playback;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _trimmer.audioPlaybackControl(startValue: 0, endValue: 0);
    _trimmer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      backgroundColor: Colors.black12,
      startingOpacity: 0.95,
      onDismissed: () {
        Navigator.of(context).pop();
        widget.setClip(start: _startValue, end: _endValue);
      },
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: widget.title,
                child: _WidgetMusic(
                  title: widget.title,
                  thumbnail: widget.thumbnail,
                  subtitle: widget.subtitle,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              isLoading
                  ? const CircularProgressIndicator()
                  : TrimViewer(
                      trimmer: _trimmer,
                      viewerHeight: 40,
                      maxAudioLength: Duration(
                        milliseconds: Provider.of<VideoDurationModel>(context)
                            .durationInMilliSeconds,
                      ),
                      viewerWidth: MediaQuery.of(context).size.width,
                      durationStyle: DurationStyle.FORMAT_MM_SS,
                      backgroundColor: Colors.white,
                      barColor: Colors.black12,
                      durationTextStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 10,
                        decoration: TextDecoration.none,
                      ),
                      allowAudioSelection: true,
                      editorProperties: TrimEditorProperties(
                        circleSize: 10,
                        borderPaintColor: Colors.blue,
                        borderWidth: 4,
                        borderRadius: 5,
                        circlePaintColor: Colors.blue.shade700,
                      ),
                      areaProperties:
                          TrimAreaProperties.edgeBlur(blurEdges: true),
                      onChangeStart: (value) {
                        _startValue = value;
                      },
                      onChangeEnd: (value) {
                        _endValue = value;
                      },
                      onChangePlaybackState: (value) async {
                        if (!value) {
                          await _trimmerplay();
                        }
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WidgetMusic extends StatelessWidget {
  String title;
  String thumbnail;
  String subtitle;
  _WidgetMusic({
    super.key,
    required this.title,
    required this.thumbnail,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.06,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(thumbnail),
                  Image.asset('assets/music2.gif'),
                ],
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      fontStyle: FontStyle.normal,
                      fontFamily: 'Inter',
                      decoration: TextDecoration.none,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    // softWrap: true,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontFamily: 'Inter',
                      decoration: TextDecoration.none,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
