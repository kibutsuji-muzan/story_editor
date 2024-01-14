import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_edit_story/components/MusicModal.dart';
import 'package:flutter_edit_story/var.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_edit_story/components/ScrollModal.dart';
import 'package:flutter_edit_story/widgets/Widget.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_edit_story/API/saavan.dart' as savaanApi;

class VideoEditPage extends StatefulWidget {
  const VideoEditPage({super.key});

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
    _controller = VideoPlayerController.asset('assets/video.mp4');
    _initController = _controller.initialize().then((_) => _controller.pause());
    _controller.setLooping(true);
    get_music();
  }

  void refresh(Widget item) {
    setState(() {
      _localactivelist.add(chooseWidget(item));
      print(_localactivelist);
    });
  }

  void get_music() async {
    print('here');
    List res = await savaanApi.topSongs();

    for (var song in res) {
      songs.add(
        Song(
          title: song['title'],
          encrypted_media_url: song['more_info']['encrypted_media_url'],
          thumbnail: song['image'],
          subtitle: song['subtitle'],
        ),
      );
    }
    print(songs[0]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
            future: _initController,
            builder: (context, snapshot) {
              return VideoPlayer(_controller);
            },
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
                          return ChangeNotifierProvider<PlayingSong>(
                            create: (context) => PlayingSong(),
                            child: MusicModal(songs: songs),
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
