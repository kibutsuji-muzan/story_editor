import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_edit_story/var.dart';
import 'package:flutter_edit_story/widgets/MusicWidget.dart';

import 'package:jiosaavn/jiosaavn.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class MusicModal extends StatefulWidget {
  Function notifyParent;

  List<Song> songs;
  MusicModal({super.key, required this.songs, required this.notifyParent});

  @override
  State<StatefulWidget> createState() => _MusicModalState();
}

class _MusicModalState extends State<MusicModal> {
  final AudioPlayer _player = AudioPlayer();
  String? _nowplaying;
  List<Song> _searched = [];
  final TextEditingController _controller = TextEditingController();
  JioSaavnClient jiosaavan = JioSaavnClient();

  void setnowplaying(String mediaKey, BuildContext ctx, String url) {
    setState(() {
      _nowplaying = mediaKey;
    });
    _playSong(ctx, url);
  }

  void _playSong(var context, String url) async {
    if (Provider.of<PlayingSong>(context, listen: false).song == null) {
      Provider.of<PlayingSong>(context, listen: false).setSong(_nowplaying!);
    }
    if (Provider.of<PlayingSong>(context, listen: false).song == _nowplaying) {
      if (!Provider.of<PlayingSong>(context, listen: false).playing) {
        Provider.of<PlayingSong>(context, listen: false).setPlayin();
        await _player.setUrl(url);
        await _player.play();
      } else {
        Provider.of<PlayingSong>(context, listen: false).setPlayin();
        await _player.pause();
      }
    }
    if ((Provider.of<PlayingSong>(context, listen: false).song !=
        _nowplaying)) {
      Provider.of<PlayingSong>(context, listen: false).setSong(_nowplaying!);
      Provider.of<PlayingSong>(context, listen: false).setPlayin();
      if (!Provider.of<PlayingSong>(context, listen: false).playing) {
        Provider.of<PlayingSong>(context, listen: false).setPlayin();
        await _player.setUrl(url);
        await _player.play();
      }
    }
  }

  Future<void> fetch_song(String query) async {
    var res = await jiosaavan.search.songs(query);
    for (var song in res.results) {
      setState(() {
        _searched.add(
          Song(
            songId: song.downloadUrl![0].link,
            thumbnail: song.image![0].link,
            title: song.name!,
            subtitle: song.primaryArtists,
          ),
        );
      });
    }
    return;
  }

  void addwidget(Widget item) {
    widget.notifyParent(item);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
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
                    controller: _controller,
                    onChanged: (value) async {
                      fetch_song(value);
                      if (_searched.isNotEmpty) {
                        _searched.clear();
                      }
                      if (Provider.of<PlayingSong>(context, listen: false)
                          .playing) {
                        Provider.of<PlayingSong>(context, listen: false)
                            .setPlayin();
                        _player.stop();
                      }
                    },
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
                        itemCount: _searched.isEmpty
                            ? widget.songs.length
                            : _searched.length,
                        itemBuilder: (context, index) {
                          return SongWidget(
                            addwidget: addwidget,
                            nowplaying: _nowplaying,
                            title: _searched.isEmpty
                                ? widget.songs[index].title
                                : _searched[index].title,
                            thumbnail: _searched.isEmpty
                                ? widget.songs[index].thumbnail
                                : _searched[index].thumbnail,
                            subtitle: _searched.isEmpty
                                ? widget.songs[index].subtitle
                                : _searched[index].subtitle,
                            setplaying: setnowplaying,
                            songVideoId: _searched.isEmpty
                                ? widget.songs[index].songId
                                : _searched[index].songId,
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
  Function addwidget;
  SongWidget({
    super.key,
    required this.title,
    required this.thumbnail,
    required this.subtitle,
    required this.songVideoId,
    required this.nowplaying,
    required this.setplaying,
    required this.addwidget,
  });

  @override
  State<SongWidget> createState() => _SongWidgetState();
}

class _SongWidgetState extends State<SongWidget> {
  JioSaavnClient jiosaavan = JioSaavnClient();

  @override
  void initState() {
    super.initState();
  }

  Future<String> getUri() async {
    String url;
    if (!widget.songVideoId.contains('https://')) {
      List res = await jiosaavan.songs.detailsById([widget.songVideoId]);
      url = res[0].downloadUrl![0].link;
    } else {
      url = widget.songVideoId;
    }
    return url;
  }

  Future<void> sendNotif() async {
    String url = await getUri();
    widget.addwidget(
      MusicWidget(
          url: url,
          title: widget.title,
          thumbnail: widget.thumbnail,
          subtitle: widget.subtitle),
    );
  }

  Future<void> _getUrl(BuildContext ctx) async {
    String url = await getUri();
    // ignore: use_build_context_synchronously
    widget.setplaying(widget.songVideoId, ctx, url);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        sendNotif();
        Navigator.of(context).pop();
      },
      child: Container(
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
                        (context.watch<PlayingSong>().song ==
                            widget.songVideoId))
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
                      widget.title,
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
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: IconButton(
                onPressed: () {
                  _getUrl(context);
                },
                icon: ((context.watch<PlayingSong>().playing) &&
                        (context.watch<PlayingSong>().song ==
                            widget.songVideoId))
                    ? const Icon(Icons.stop_circle_rounded)
                    : const Icon(Icons.play_circle_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
