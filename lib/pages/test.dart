import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';

import 'package:flutter_edit_story/var.dart';
import 'package:http/http.dart' as http;
import 'package:easy_audio_trimmer/easy_audio_trimmer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:provider/provider.dart';

final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: MusicWidget(
        url:
            'https://aac.saavncdn.com/773/6e69a112de89c7655116dcf400019f9c_12.mp4',
        title: 'title',
        thumbnail:
            'https://c.saavncdn.com/433/Shikayat-Hindi-2023-20231214181447-150x150.jpg',
        subtitle: 'subtitle',
      ),
    );
  }
}

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

class _MusicWidgetState extends State<MusicWidget> {
  final String gifAsset = 'assets/music.gif';
  late final Trimmer _trimmer;
  double _start = 0;
  double _end = 0;

  late File _file;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _trimmer = Trimmer();
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
    String filename = '${tempDir.path}/${widget.url.length}.mp4';
    bool fileExists = await File(filename).exists();
    File file = File(filename);
    if (!fileExists) {
      await file.writeAsBytes(res.bodyBytes);
    }
    setState(() {
      _file = file;
    });
    _loadAudio();
  }

  void _loadAudio() async {
    await _trimmer.loadAudio(audioFile: _file).then((value) => _trimmerplay());
  }

  Future<void> _trimmerplay() async {
    print('$_start , $_end');
    print(_file.path);

    await _trimmer.audioPlaybackControl(
      startValue: _start,
      endValue: _end,
    );
  }

  void _setClip(bool again, Trimmer? trimmer,
      {required double start, required double end}) async {
    // print(_file.path);
    setState(() {
      _start = start;
      _end = end;
    });
    if (again) {
      // print(_file.path);
      await trimmer!.audioPlaybackControl(startValue: start, endValue: end);
    } else {
      await _trimmerplay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            context.pushTransparentRoute(
              _TrimmingPage(
                url: widget.url,
                title: widget.title,
                thumbnail: widget.thumbnail,
                subtitle: widget.subtitle,
                setClip: _setClip,
                trimmer: _trimmer,
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
        ),
        IconButton.filled(
          onPressed: () {
            _trimmer.audioPlayer!.dispose();
          },
          icon: const Icon(
            Icons.stop_circle,
          ),
        ),
      ],
    );
  }
}

class _TrimmingPage extends StatefulWidget {
  String url;
  String title;
  String thumbnail;
  String subtitle;
  Function setClip;
  Trimmer trimmer;
  _TrimmingPage({
    super.key,
    required this.url,
    required this.title,
    required this.thumbnail,
    required this.subtitle,
    required this.setClip,
    required this.trimmer,
  });

  @override
  State<_TrimmingPage> createState() => _TrimmingPageState();
}

class _TrimmingPageState extends State<_TrimmingPage> {
  double _startValue = 0.0;
  double _endValue = 0.0;
  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      backgroundColor: Colors.black12,
      startingOpacity: 0.95,
      onDismissed: () {
        widget.setClip(
          true,
          widget.trimmer,
          start: _startValue,
          end: _endValue,
        );
        Navigator.of(context).pop();
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
              TrimViewer(
                trimmer: widget.trimmer,
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
                areaProperties: TrimAreaProperties.edgeBlur(blurEdges: true),
                onChangeStart: (value) {
                  setState(() {
                    _startValue = value;
                  });
                },
                onChangeEnd: (value) {
                  setState(() {
                    _endValue = value;
                  });
                },
                onChangePlaybackState: (value) async {
                  if (!value) {
                    await widget.setClip(
                      false,
                      start: _startValue,
                      end: _endValue,
                    );
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
