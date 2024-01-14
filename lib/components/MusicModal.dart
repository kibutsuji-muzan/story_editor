import 'dart:convert';

import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_edit_story/var.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:provider/provider.dart';

class MusicModal extends StatefulWidget {
  List<Song> songs;
  MusicModal({super.key, required this.songs});

  @override
  State<StatefulWidget> createState() => _MusicModalState();
}

class _MusicModalState extends State<MusicModal> {
  String? _nowplaying;

  void setnowplaying(String mediaKey) {
    setState(() {
      _nowplaying = mediaKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 0.95,
      minChildSize: 0.1,
      initialChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          margin: const EdgeInsets.only(top: 50),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadiusDirectional.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Column(
              children: [
                Container(
                  height: 5,
                  margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  height: MediaQuery.of(context).size.height * 0.045,
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black12,
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
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText: 'Search',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      hintStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverList.builder(
                        itemCount: widget.songs.length,
                        itemBuilder: (context, index) {
                          return SongWidget(
                            nowplaying: _nowplaying,
                            title: widget.songs[index].title,
                            thumbnail: widget.songs[index].thumbnail,
                            subtitle: widget.songs[index].subtitle,
                            setplaying: setnowplaying,
                            songVideoId:
                                widget.songs[index].encrypted_media_url,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SongWidget extends StatefulWidget {
  String title;
  String thumbnail;
  String subtitle;
  String songVideoId;
  String? nowplaying;
  Function setplaying;
  SongWidget({
    super.key,
    required this.title,
    required this.thumbnail,
    required this.subtitle,
    required this.songVideoId,
    required this.nowplaying,
    required this.setplaying,
  });

  @override
  State<SongWidget> createState() => _SongWidgetState();
}

class _SongWidgetState extends State<SongWidget> {
  bool _playing = false;
  final AudioPlayer player = AudioPlayer();
  Future<String> _getUrl() async {
    String url;
    var res = await http.post(
      Uri.https("jio-saavan-unofficial.p.rapidapi.com", "/getsong"),
      headers: {
        'content-type': 'application/json',
        'X-RapidAPI-Key': '04316b5bebmshf8cf862f74e9ee0p1d9076jsne54e53336856',
        'X-RapidAPI-Host': 'jio-saavan-unofficial.p.rapidapi.com'
      },
      body: jsonEncode({
        "encrypted_media_url": widget.songVideoId,
      }),
    );
    url = jsonDecode(res.body)['results'][0]['96_kbps'];
    return url;
  }

  void _playSong(var context) async {
    String url =
        'https://aac.saavncdn.com/410/89df395f63b3b0a409a56c0417b04299_96.mp4';
    Provider.of<PlayingSong>(context, listen: false)
        .setSong(widget.songVideoId);

    if (context.watch<PlayingSong>().song == null) {
      await player.setUrl(url);
      await player.play();
    } else if (context.watch<PlayingSong>().song == widget.songVideoId) {
      Provider.of<PlayingSong>(context, listen: false)
          .setSong(widget.songVideoId);
      if (!context.watch<PlayingSong>().playing) {
        await player.setUrl(url);
        await player.play();
      } else {
        await player.pause();
      }
    } else {
      Provider.of<PlayingSong>(context, listen: false)
          .setSong(widget.songVideoId);
    }
    // String url = await _getUrl();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      height: MediaQuery.of(context).size.height * 0.06,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(widget.thumbnail, fit: BoxFit.scaleDown),
                  if ((context.watch<PlayingSong>().playing) &&
                      (context.watch<PlayingSong>().song == widget.songVideoId))
                    Image.asset('assets/music2.gif'),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 2,
                horizontal: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.watch<PlayingSong>().song.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: IconButton(
              onPressed: () {
                _playSong(context);
              },
              icon: ((context.watch<PlayingSong>().playing) &&
                      (context.watch<PlayingSong>().song == widget.songVideoId))
                  ? const Icon(Icons.pause_circle_outline_rounded)
                  : const Icon(Icons.play_circle_outline_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
