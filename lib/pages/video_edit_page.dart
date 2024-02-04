import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_edit_story/components/MusicModal.dart';
import 'package:flutter_edit_story/components/ProductModal.dart';
import 'package:flutter_edit_story/pages/home_page.dart';
import 'package:flutter_edit_story/var.dart';
import 'package:flutter_edit_story/widgets/MusicWidget.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_edit_story/components/ScrollModal.dart';
import 'package:flutter_edit_story/widgets/Widget.dart';
import 'package:flutter_edit_story/API/saavan.dart' as savaanApi;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

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
          .removeKey(key: const Key('music'));
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
    await VideoCompress.getFileThumbnail(
      videopath,
      quality: 50,
      position: -1,
    );
  }

  Future<String> compressvideo(
    String videopath,
    bool audio,
    Directory sourceDir,
  ) async {
    _subscription = VideoCompress.compressProgress$.subscribe((progress) {
      debugPrint('progress: $progress');
    });
    late File _file;
    await VideoCompress.compressVideo(
      videopath,
      quality: VideoQuality.LowQuality,
      deleteOrigin: false,
      includeAudio: audio,
    ).then((value) async {
      _file = await value!.file!.copy('${sourceDir.path}/file.mp4');
      value.file!.delete();
    });
    _subscription.unsubscribe();

    return _file.path;
  }

  Future<String> compressimage(
    String path,
    String targetPath,
    Directory sourceDir,
  ) async {
    String outPath = '${sourceDir.path}/file.jpg';
    await FlutterImageCompress.compressAndGetFile(
      path,
      targetPath,
      quality: 50,
      rotate: 0,
    ).then((value) async {
      await value!.saveTo(outPath);
      await File(value.path).delete();
    });

    return outPath;
  }

  Future<File> _createZip(String json, String file, Directory sourceDir) async {
    final files = [File(json), File(file)];
    final zipFile = File('${sourceDir.path}/story.zip');
    try {
      ZipFile.createFromFiles(
        sourceDir: sourceDir,
        files: files,
        zipFile: zipFile,
      );
    } catch (e) {
      print(e);
    }
    return zipFile;
  }

  Future<String> saveVideo(Directory tempDir) async {
    if (_audioplaying && widget.video) {
      await compressvideo(widget.file.path, false, tempDir)
          .then((value) => setState(() => outPath = value));
    } else if (!widget.video) {
      await compressimage(
              widget.file.path, '${tempDir.path}/result.jpg', tempDir)
          .then((value) => setState(() => outPath = value));
    } else {
      await compressvideo(widget.file.path, true, tempDir)
          .then((value) => setState(() => outPath = value));
    }
    return outPath;
  }

  Future<String> saveJson(String tempDir) async {
    File _file = File('$tempDir/data.json');
    List widgets = [];
    Provider.of<ActiveWidget>(context, listen: false)
        .widgetlist
        .forEach((element) {
      widgets.add(
        CustomClass.toJson(
          val: element,
        ),
      );
    });
    var j = {
      'user': {'username': 'dummy', 'id': 5},
      'widgets': widgets,
    };
    await _file.writeAsString(json.encode(j));
    return _file.path;
  }

  Future<void> postStory() async {
    Directory tempDir = await getTemporaryDirectory();
    Directory workplace =
        await Directory('${tempDir.path}/story').create(recursive: true);
    String video = await saveVideo(workplace);
    String json = await saveJson(workplace.path);
    var file = await _createZip(
      video,
      json,
      workplace,
    );
    await sendFile(file: file).then((value) {
      Provider.of<SelectedProduct>(context, listen: false).setProductId(0);
      Provider.of<ActiveWidget>(context, listen: false).removeAll();
    });
  }

  Future<int> sendFile({required File file}) async {
    int pid = Provider.of<SelectedProduct>(context, listen: false).productId;
    print(file.path);
    var request = http.MultipartRequest(
      'POST',
      Uri.https(domain, '/api/story_upload'),
    );
    request.headers.addAll(
      {
        'Authorization': 'Bearer $token',
      },
    );
    if (pid != 0) request.fields['product_id'];
    request.files.add(
      http.MultipartFile.fromBytes(
        'story',
        file.readAsBytesSync(),
        filename: path.basename(file.path),
      ),
    );
    var res = await request.send();
    var resp = await http.Response.fromStream(res);
    print(resp.body);
    return res.statusCode;
  }

  Widget widgetchooser(
    Key widget,
    String link,
    Key key,
    String title,
    String thumbnail,
    String subtitle,
  ) {
    switch (widget) {
      case const Key('gif'):
        return Image.network(key: key, link);
      case const Key('sticker'):
        return Image.network(key: key, link);
      case const Key('music'):
        return MusicWidget(
          url: link,
          title: title,
          thumbnail: thumbnail,
          subtitle: subtitle,
        );
      default:
        return const Text('data');
    }
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
              for (Map<String, dynamic> elem
                  in context.watch<ActiveWidget>().widgetlist)
                WidgetItem(
                  key: elem['key'],
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
                            if (element['key'] == const Key('Music')) {
                              _audioplaying = false;
                              if (widget.video) _controller.setVolume(100);
                            }
                            return element['key'] == key;
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
                  widget: widgetchooser(
                    elem['widget'],
                    elem['link'],
                    elem['key'],
                    elem['title'] ?? '',
                    elem['thumbnail'] ?? '',
                    elem['subtitle'] ?? '',
                  ),
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
                    onPressed: () => postStory().then(
                      (value) => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const HomePage();
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