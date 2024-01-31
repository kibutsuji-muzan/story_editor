import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_edit_story/components/MusicModal.dart';
import 'package:flutter_edit_story/components/ProductModal.dart';
import 'package:flutter_edit_story/pages/output_page.dart';
import 'package:flutter_edit_story/var.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_edit_story/components/ScrollModal.dart';
import 'package:flutter_edit_story/widgets/Widget.dart';
import 'package:flutter_edit_story/API/saavan.dart' as savaanApi;

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
  List<Song> songs = [];
  late String outPath;
  late Subscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = VideoCompress.compressProgress$.subscribe((progress) {
      debugPrint('progress: $progress');
    });
    if (widget.video) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.file.path),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: true,
        ),
      );

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
    Provider.of<ActiveWidget>(context, listen: false)
        .addWidget({'widget': chooseWidget(item)});
    setState(() {});

    if (item.key == const Key('Music')) {
      setState(() => _audioplaying = true);
      _controller.setVolume(0);
    }
  }

  void removeMusic() {
    setState(() {
      Provider.of<ActiveWidget>(context, listen: false)
          .removeKey(key: const Key('Music'));
      setState(() {
        _audioplaying = false;
      });
      if (widget.video) _controller.setVolume(100);
    });
  }

  void get_music() async {
    List res = await savaanApi.topSongs();

    for (var song in res) {
      songs.add(
        Song(
          link: song['id'],
          title: song['title'],
          thumbnail: song['image'],
          subtitle: song['subtitle'],
        ),
      );
    }
  }

  Future getthumbnail(String videopath) async {
    final thumbnailFile = await VideoCompress.getFileThumbnail(
      videopath,
      quality: 50,
      position: -1,
    );
  }

  Future compressvideo(String videopath, bool audio) async {
    var mediaInfo = await VideoCompress.compressVideo(
      videopath,
      quality: VideoQuality.LowQuality,
      deleteOrigin: false,
      includeAudio: audio,
    );
    setState(() {
      outPath = mediaInfo!.file!.path;
    });
    return mediaInfo!.file!.path;
  }

  Future<XFile?> compressimage(String path, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      path,
      targetPath,
      quality: 50,
      rotate: 0,
    );

    return result;
  }

  Future<void> saveVideo() async {
    print(Provider.of<ActiveWidget>(context, listen: false).widgetlist);
    // Directory tempDir = await getTemporaryDirectory();
    // setState(() {
    //   outPath = '${tempDir.path}/result.jpg';
    // });
    // getthumbnail(widget.file.path);

    // if (_audioplaying && widget.video) {
    //   await compressvideo(widget.file.path, false);
    // } else if (!widget.video) {
    //   await compressimage(widget.file.path, outPath);
    // } else {
    //   await compressvideo(widget.file.path, true);
    // }
  }

  @override
  void dispose() {
    if (widget.video) {
      _controller.dispose();
    }
    super.dispose();
    _subscription.unsubscribe();
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
              for (Map<String, dynamic> elem
                  in context.read<ActiveWidget>().widgetlist)
                WidgetItem(
                  key: elem['widget'].key,
                  onDragEnd: (offset, key) {
                    if ((offset.dy >
                            (MediaQuery.of(context).size.height - 100)) &&
                        (offset.dx <
                                (MediaQuery.of(context).size.width * 0.6) &&
                            (offset.dx >
                                (MediaQuery.of(context).size.width * 0.4)))) {
                      setState(() {
                        Provider.of<ActiveWidget>(context, listen: false)
                            .widgetlist
                            .removeWhere(
                          (element) {
                            if (element['widget'].key == const Key('Music')) {
                              _audioplaying = false;
                              if (widget.video) _controller.setVolume(100);
                            }
                            return element['widget'].key == key;
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
                  widget: elem['widget'],
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
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black26,
                        ),
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
                          isScrollControlled: true,
                          builder: (context) {
                            return ProductModal(
                              notifyParent: refresh,
                            );
                          },
                        ),
                        splashColor: Colors.white,
                        icon: Icon(
                          (Provider.of<SelectedProduct>(context).productId != 0)
                              ? Icons.shopping_cart_rounded
                              : Icons.shopping_cart_outlined,
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
                    onPressed: () => saveVideo().then(
                      (value) => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return OutputPage(video: File(outPath));
                          },
                        ),
                      ),
                    ),
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