import 'package:flutter/material.dart';
import 'package:flutter_edit_story/components/ScrollModal.dart';
import 'package:just_audio/just_audio.dart';

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

class _MusicWidgetState extends State<MusicWidget>
    with TickerProviderStateMixin {
  final String gifAsset = 'assets/music.gif';
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    print(widget.url);
    _player.setUrl(widget.url);
    _player.play();
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
  }

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
                  Image.network(widget.thumbnail),
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
                    widget.title,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.subtitle,
                    // softWrap: true,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
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
