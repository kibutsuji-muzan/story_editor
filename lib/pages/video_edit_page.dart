import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_edit_story/components/MusicModal.dart';
import 'package:flutter_edit_story/var.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_edit_story/components/ScrollModal.dart';
import 'package:flutter_edit_story/widgets/Widget.dart';
import 'package:flutter_edit_story/API/saavan.dart' as savaanApi;

import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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
  bool _audio = true;
  bool _deleteButton = false;
  bool _deleteButtonActive = false;
  final List<Widget> _localactivelist = [];
  List<Song> songs = [];
  @override
  void initState() {
    super.initState();
    if (widget.video) {
      _controller =
          // VideoPlayerController.networkUrl(Uri.parse(widget.file.path));
          VideoPlayerController.asset('assets/video.mp4');
      _initController = _controller.initialize().then((_) {
        Provider.of<VideoDurationModel>(
          context,
          listen: false,
        ).setDurationInMilliSeconds(
          _controller.value.duration.inMilliseconds,
        );
        _controller.pause();
      });
      _controller.setLooping(true);
    }
    get_music();
  }

  void refresh(Widget item) {
    for (var i in _localactivelist) {
      if (i.key == item.key) {
        _localactivelist.remove(i);
      }
    }
    setState(() {
      _localactivelist.add(chooseWidget(item));
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
      body: Stack(
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
                if ((offset.dy > (MediaQuery.of(context).size.height - 100)) &&
                    (offset.dx < (MediaQuery.of(context).size.width * 0.6) &&
                        (offset.dx >
                            (MediaQuery.of(context).size.width * 0.4)))) {
                  setState(() {
                    _localactivelist.removeWhere(
                      (element) => element.key == key,
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
                if ((offset.dy > (MediaQuery.of(context).size.height - 100)) &&
                    (offset.dx < (MediaQuery.of(context).size.width * 0.6) &&
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
                        color:
                            (_deleteButtonActive) ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                )
              : Container(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              child: Align(
                alignment: Alignment.topRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.video)
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
                      onPressed: () => showModalBottomSheet(
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
                      ),
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
          ),
        ],
      ),
    );
  }
}
