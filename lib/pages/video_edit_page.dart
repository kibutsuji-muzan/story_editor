import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_edit_story/components/MusicModal.dart';
import 'package:flutter_edit_story/var.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_edit_story/components/ScrollModal.dart';
import 'package:flutter_edit_story/widgets/Widget.dart';
import 'package:flutter_edit_story/API/saavan.dart' as savaanApi;
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';

class VideoEditPage extends StatefulWidget {
  XFile file;
  bool video;
  VideoEditPage({
    super.key,
    required this.file,
    required this.video,
  });

  @override
  State<StatefulWidget> createState() => _VideoEditPageState();
}

class _VideoEditPageState extends State<VideoEditPage> {
  late VideoPlayerController _controller;
  late Future<void> _initController;
  bool _audioplaying = false;
  bool _audio = true;
  bool _deleteButton = false;
  bool _deleteButtonActive = false;
  final List<Widget> _localactivelist = [];
  List<Song> songs = [];

  @override
  void initState() {
    super.initState();
    if (widget.video) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.file.path),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: true,
        ),
      );
      // VideoPlayerController.asset(
      //   'assets/video.mp4',
      //   videoPlayerOptions: VideoPlayerOptions(
      //     mixWithOthers: true,
      //     allowBackgroundPlayback: true,
      //   ),
      // );
      _initController = _controller.initialize().then((_) {
        Provider.of<VideoDurationModel>(
          context,
          listen: false,
        ).setDurationInMilliSeconds(
          _controller.value.duration.inMilliseconds,
        );
        _controller.setLooping(true);
        _controller.play();
      });
    } else {
      Provider.of<VideoDurationModel>(
        context,
        listen: false,
      ).setDurationInMilliSeconds(60000);
    }
    get_music();
  }

  void refresh(Widget item) {
    setState(() {
      _localactivelist.add(chooseWidget(item));
    });
    if (item.key == const Key('Music')) {
      setState(() {
        _audioplaying = true;
      });
      _controller.setVolume(0);
    }
  }

  void removeMusic() {
    setState(() {
      _localactivelist.removeWhere((element) => element.key == Key('Music'));
      setState(() {
        _audioplaying = false;
      });
      _controller.setVolume(100);
    });
  }

  void get_music() async {
    List res = await savaanApi.topSongs();

    for (var song in res) {
      songs.add(
        Song(
          songId: song['id'],
          title: song['title'],
          thumbnail: song['image'],
          subtitle: song['subtitle'],
        ),
      );
    }
  }

  Future<void> saveVideo() async {
    Directory tempDir = await getTemporaryDirectory();
    var outPath = '${tempDir.path}/results/output.mp4';
    var audio = Provider.of<TrimmedAudio>(context, listen: false).outputPath;
    var cmd =
        "-i ${widget.file.path} -i ${audio} -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 ${outPath}";
    debugPrint(cmd);
    await FFmpegKit.execute(cmd);
  }

  @override
  void dispose() {
    if (widget.video) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            children: [
              (widget.video)
                  ? FutureBuilder(
                      future: _initController,
                      builder: (context, snapshot) {
                        return VideoPlayer(_controller);
                      },
                    )
                  : Image.file(
                      File(widget.file.path),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    ),
              for (Widget elem in _localactivelist)
                WidgetItem(
                  key: elem.key,
                  onDragEnd: (offset, key) {
                    if ((offset.dy >
                            (MediaQuery.of(context).size.height - 100)) &&
                        (offset.dx <
                                (MediaQuery.of(context).size.width * 0.6) &&
                            (offset.dx >
                                (MediaQuery.of(context).size.width * 0.4)))) {
                      setState(() {
                        _localactivelist.removeWhere(
                          (element) {
                            if (element.key == Key('Music')) {
                              _audioplaying = false;
                              _controller.setVolume(100);
                            }
                            return element.key == key;
                          },
                        );
                      });
                    }
                    setState(() {
                      _deleteButton = false;
                    });
                  },
                  onDragStart: () {
                    setState(() {
                      _deleteButton = true;
                    });
                  },
                  onDragUpdate: (offset, key) {
                    if ((offset.dy >
                            (MediaQuery.of(context).size.height - 100)) &&
                        (offset.dx <
                                (MediaQuery.of(context).size.width * 0.6) &&
                            (offset.dx >
                                (MediaQuery.of(context).size.width * 0.4)))) {
                      setState(() {
                        _deleteButtonActive = true;
                      });
                    } else {
                      setState(() {
                        _deleteButtonActive = false;
                      });
                    }
                  },
                  widget: elem,
                ),
              (_deleteButton)
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: (_deleteButtonActive)
                                ? const Color.fromARGB(174, 239, 83, 80)
                                : Colors.white38,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Icon(
                            Icons.delete_forever,
                            size: (_deleteButtonActive) ? 30 : 20,
                            color: (_deleteButtonActive)
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                    )
                  : Container(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.video && !_audioplaying)
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black26,
                          ),
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
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black26,
                        ),
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
                          isScrollControlled: true,
                          builder: (context) {
                            return ScrollModal(notifyParent: refresh);
                          },
                        ),
                        splashColor: Colors.white,
                        icon: const Icon(
                          Icons.emoji_symbols_rounded,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black26,
                        ),
                        onPressed: () {
                          removeMusic();
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
                            isScrollControlled: true,
                            builder: (context) {
                              return MultiProvider(
                                providers: [
                                  ChangeNotifierProvider(
                                      create: (_) => PlayingSong()),
                                  ChangeNotifierProvider(
                                      create: (context) => VideoDurationModel())
                                ],
                                child: MusicModal(
                                  songs: songs,
                                  notifyParent: refresh,
                                ),
                              );
                            },
                          );
                        },
                        splashColor: Colors.white,
                        icon: const Icon(
                          Icons.library_music_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 15,
                      ),
                      backgroundColor: Theme.of(context).canvasColor,
                    ),
                    onPressed: () => saveVideo(),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.14,
                      child: const Row(
                        children: [
                          Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 15,
                            color: Colors.black,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Post',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//Use This To Merge Audio And Video
// ffmpeg -i video.mp4 -i audio.wav -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 output.mp4