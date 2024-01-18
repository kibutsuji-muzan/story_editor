import 'package:flutter/material.dart';
import 'package:flutter_edit_story/widgets/MusicWidget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_edit_story/widgets/PollsWidget.dart';

enum grp { Yes, No }

chooseWidget(Widget item) {
  switch (item) {
    case PollsWidget():
      return PollsWidget(key: UniqueKey());
    case SvgPicture():
      return SvgPicture.asset(
        key: UniqueKey(),
        'assets/sticker.svg',
        width: 100,
      );
    case MusicWidget():
      return item;
    default:
      return new Text('hello');
  }
}

List allWidgetsList = [
  PollsWidget(),
  SvgPicture.asset(
    'assets/sticker.svg',
    width: 100,
  ),
];

class Song {
  final String songId;
  final String title;
  final String thumbnail;
  final String subtitle;

  const Song({
    required this.songId,
    required this.title,
    required this.thumbnail,
    required this.subtitle,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'songId': String songId,
        'title': String title,
        'thumbnail': String thumbnail,
        'subtitle': String subtitle,
      } =>
        Song(
          songId: songId,
          title: title,
          thumbnail: thumbnail,
          subtitle: subtitle,
        ),
      _ => throw const FormatException('Failed to load Song.'),
    };
  }
}

class PlayingSong with ChangeNotifier {
  String? _song = null;
  bool _playing = false;

  String? get song => _song;
  bool get playing => _playing;

  void setPlayin() {
    _playing = !_playing;
    notifyListeners();
  }

  void setSong(String s) {
    _song = s;
    notifyListeners();
  }
}

class PlayerWidget with ChangeNotifier {}
