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
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';

class MusicWidget extends StatefulWidget {
  String url;
  String title;
  String thumbnail;
  String subtitle;
  Key key = Key('Music');
  MusicWidget({
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
  late File _file;
  final AudioPlayer _player = AudioPlayer();
  @override
  void initState() {
    print('object');
    super.initState();
    saveSong().then((value) {
      context.pushTransparentRoute(
        _TrimmingPage(
          file: _file,
          title: widget.title,
          thumbnail: widget.thumbnail,
          subtitle: widget.subtitle,
          setClip: playSong,
        ),
      );
    });
  }

  void playSong({required File file}) async {
    print(_player);
    await _player.setFilePath(file.path);
    print('hello have a cup cake!! ${file.path}');
    _player.setLoopMode(LoopMode.one);
    _player.play();
  }

  Future<void> saveSong() async {
    print(_player);
    var res = await http.get(
      Uri.parse(widget.url),
    );
    Directory tempDir = await getTemporaryDirectory();
    String filename = '${tempDir.path}/${widget.url.length}.mp4';
    File file = File(filename);

    await file.writeAsBytes(res.bodyBytes);

    setState(() {
      _file = file;
    });
    // playSong(file: file);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushTransparentRoute(
          _TrimmingPage(
            file: _file,
            title: widget.title,
            thumbnail: widget.thumbnail,
            subtitle: widget.subtitle,
            setClip: playSong,
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
  File file;
  String title;
  String thumbnail;
  String subtitle;
  Function setClip;
  _TrimmingPage({
    super.key,
    required this.file,
    required this.title,
    required this.thumbnail,
    required this.subtitle,
    required this.setClip,
  });

  @override
  State<_TrimmingPage> createState() => _TrimmingPageState();
}

class _TrimmingPageState extends State<_TrimmingPage> {
  Duration _startValue = Duration(milliseconds: 0);
  Duration _endValue = Duration(milliseconds: 0);

  final Trimmer _trimmer = Trimmer();
  // late File _file;
  bool _isPlaying = true;
  // bool _progressVisibility = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAudio();
  }

  String randomHexString(int length) {
    Random _random = Random();
    StringBuffer sb = StringBuffer();
    for (var i = 0; i < length; i++) {
      sb.write(_random.nextInt(16).toRadixString(16));
    }
    return sb.toString();
  }

  void _loadAudio() async {
    setState(() {
      isLoading = true;
    });

    await _trimmer
        .loadAudio(audioFile: widget.file)
        .then((value) => _trimmerplay());

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _trimmerplay() async {
    debugPrint('trimmerPlayed');
    await _trimmer.audioPlaybackControl(
        startValue: _startValue.inMilliseconds.toDouble(),
        endValue: _endValue.inMilliseconds.toDouble());
  }

  Future<void> _saveAudio() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      var outPath = '${tempDir.path}/output.mp4';
      var cmd =
          "-y -i ${_trimmer.currentAudioFile?.path} -vn -ss ${_startValue} -to ${_endValue} -ar 16k -ac 2 -b:a 96k -acodec copy $outPath";
      debugPrint(cmd);
      Provider.of<TrimmedAudio>(context, listen: false).setOutputPath(outPath);
      await FFmpegKit.execute(cmd);
      debugPrint('hello have this cupcake $outPath');
    } catch (e) {
      debugPrint('error: $e');
    }
  }

  Future<void> close() async {
    await _saveAudio().then((value) => widget.setClip(
          file: File(
              Provider.of<TrimmedAudio>(context, listen: false).outputPath),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _trimmer.audioPlayer!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      backgroundColor: Colors.black12,
      startingOpacity: 0.6,
      onDismissed: () async {
        setState(() {
          _isPlaying = false;
        });
        close().then(
          (value) => Navigator.of(context).pop(),
        );
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
                      allowAudioSelection: false,
                      backgroundColor: Colors.white,
                      barColor: Colors.black12,
                      durationTextStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 10,
                        decoration: TextDecoration.none,
                      ),
                      editorProperties: TrimEditorProperties(
                        circleSize: 0,
                        borderPaintColor: Colors.blue,
                        borderWidth: 4,
                        borderRadius: 5,
                        circlePaintColor: Colors.blue.shade700,
                      ),
                      areaProperties: TrimAreaProperties.fixed(
                          borderRadius: 10, barFit: BoxFit.cover),
                      showDuration: true,
                      onChangeStart: (value) {
                        _startValue = Duration(milliseconds: value.toInt());
                      },
                      onChangeEnd: (value) {
                        _endValue = Duration(milliseconds: value.toInt());
                      },
                      onChangePlaybackState: (value) async {
                        if (!value) {
                          if (_isPlaying) {
                            await _trimmerplay();
                          }
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
