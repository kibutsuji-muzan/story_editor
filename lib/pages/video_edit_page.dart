import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_edit_story/components/MusicModal.dart';
import 'package:flutter_edit_story/components/ProductModal.dart';
import 'package:flutter_edit_story/main.dart';
import 'package:flutter_edit_story/pages/home_page.dart';
import 'package:flutter_edit_story/var.dart';
import 'package:flutter_edit_story/widgets/MusicWidget.dart';
import 'package:flutter_edit_story/widgets/TimerWidget.dart';
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
import 'package:wheel_chooser/wheel_chooser.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

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
      // _controller = VideoPlayerController.asset(
      //   widget.file.path,
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
      debugPrint(e.toString());
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
    File file = await _createZip(
      video,
      json,
      workplace,
    );
    while (!await file.exists()) {
      await Future.delayed(const Duration(seconds: 3));
    }
    await sendFile(file: file).then((value) {
      if (value == 200) {
        Provider.of<SelectedProduct>(context, listen: false).setProductId(0);
        Provider.of<ActiveWidget>(context, listen: false).removeAll();
        workplace.delete(recursive: true);
      }
    });
  }

  Future<int> sendFile({required File file}) async {
    int pid = Provider.of<SelectedProduct>(context, listen: false).productId;
    debugPrint(file.path);
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
    debugPrint(resp.body);
    return res.statusCode;
  }

  Widget widgetchooser({required Map<String, dynamic> data}) {
    debugPrint(data.toString());
    switch (data['widget']) {
      case const Key('gif'):
        return Image.network(data['link'], key: data['key']);
      case const Key('sticker'):
        return Image.network(data['link'], key: data['key']);
      case const Key('music'):
        return MusicWidget(
          url: data['link'],
          title: data['title'],
          thumbnail: data['thumbnail'],
          subtitle: data['subtitle'],
        );
      case const Key('text'):
        return textWidget(
          key: data['key'],
          data: data['data'],
          color: data['color'],
          font: data['font'],
        );
      case const Key('timer'):
        return TimerWidget(
          duration: Provider.of<DurationTimer>(context).timer,
          createdAt: '2024-03-04T02:32:49.000000Z',
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
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  context.pushTransparentRoute(
                      TextEditPage(data: null, notifyParent: refresh));
                },
                child: (widget.video)
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
                  widget: widgetchooser(data: elem),
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

class TextEditPage extends StatefulWidget {
  Function notifyParent;
  String? data;
  String? color;
  String? font;
  TextEditPage({
    super.key,
    this.data,
    this.color,
    this.font,
    required this.notifyParent,
  });

  @override
  State<TextEditPage> createState() => _TextEditPageState();
}

class _TextEditPageState extends State<TextEditPage> {
  final TextEditingController _txtcontroller = TextEditingController();
  int findex = 0;
  int cindex = 0;

  FocusNode focusNode = FocusNode();
  List<String> fonts = [
    'Inter',
    'AbrilFatface',
    'BabasNeue',
    'DancingScript',
    'KolkerBrush',
    'ProtestRevolution',
    'ProtestStrike',
    'RubikDoodleShadow',
    'RubikGlitchPop',
    'ZenTokyoZoo',
  ];
  List<String> colors = [
    '#ffffff',
    '#000000',
    '#845EC2',
    '#D65DB1',
    '#FF6F91',
    '#FF9671',
    '#FFC75F',
    '#2C73D2',
    '#FBEAFF',
    '#B0A8B9',
    '#4FFBDF',
  ];
  @override
  void initState() {
    super.initState();
    debugPrint(widget.color);
    debugPrint(widget.font);
    if (widget.color != null) {
      setState(() {
        cindex = colors.indexOf(widget.color ?? '#000000');
      });
    }
    if (widget.font != null) {
      setState(() {
        findex = fonts.indexOf(widget.font ?? 'Inter');
      });
    }
    _txtcontroller.text = widget.data ?? '';
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _txtcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.05,
              child: WheelChooser.custom(
                // magnification: 1.1,
                startPosition: 0,
                onValueChanged: (s) => setState(() => cindex = s),
                horizontal: true,
                perspective: 0.00000001,
                children: List.generate(
                  colors.length,
                  (indx) => Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.width * 0.07,
                        width: MediaQuery.of(context).size.width * 0.07,
                        decoration: BoxDecoration(
                          color: (indx == cindex)
                              ? Colors.white54
                              : Colors.black12,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.width * 0.06,
                        width: MediaQuery.of(context).size.width * 0.06,
                        decoration: BoxDecoration(
                          color: colors[indx].hextocolor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            TextField(
              focusNode: focusNode,
              autofocus: true,
              maxLines: null,
              style: TextStyle(
                fontSize: 30,
                color: colors[cindex].hextocolor,
                fontFamily: fonts[findex],
                decoration: TextDecoration.none,
                decorationColor: const Color.fromRGBO(0, 0, 0, 0),
                // decorationStyle: TextDecorationStyle.wavy,
              ),
              keyboardType: TextInputType.text,
              onSubmitted: (value) {
                if (widget.key == null) {
                  Provider.of<ActiveWidget>(context, listen: false).addWidget({
                    'widget': const Key('text'),
                    'key': UniqueKey(),
                    'font': fonts[findex],
                    'color': colors[cindex],
                    'data': _txtcontroller.text,
                  });
                } else {
                  Provider.of<ActiveWidget>(context, listen: false)
                      .update(key: widget.key ?? const Key(''), data: {
                    'font': fonts[findex],
                    'color': colors[cindex],
                    'data': _txtcontroller.text,
                  });
                }
              },
              textAlign: TextAlign.center,
              controller: _txtcontroller,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color.fromRGBO(0, 0, 0, 0),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    style: BorderStyle.none,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    style: BorderStyle.none,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.05,
              child: WheelChooser.custom(
                // magnification: 1.1,
                startPosition: 0,
                onValueChanged: (s) => setState(() => findex = s),
                horizontal: true,
                perspective: 0.0001,
                children: List.generate(
                  fonts.length,
                  (indx) => Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.1,
                        decoration: BoxDecoration(
                          color: (indx == findex)
                              ? Colors.white54
                              : Colors.black12,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      Text(
                        'Aa',
                        style: TextStyle(
                          fontSize: 20,
                          color: (indx == findex) ? Colors.black : Colors.white,
                          fontFamily: fonts[indx],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class textWidget extends StatelessWidget {
  String data;
  String font;
  String color;
  textWidget({
    super.key,
    required this.data,
    required this.color,
    required this.font,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushTransparentRoute(
        TextEditPage(
          key: key,
          data: data,
          color: color,
          font: font,
          notifyParent: () {},
        ),
      ),
      child: Text(
        data,
        style: TextStyle(
          fontFamily: font,
          fontSize: 50,
          color: color.hextocolor,
        ),
      ),
    );
  }
}
