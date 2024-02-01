import 'package:flutter/material.dart';
import 'package:flutter_edit_story/widgets/MusicWidget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_edit_story/widgets/PollsWidget.dart';

enum grp { Yes, No }

chooseWidget(Widget item) {
  print(item);
  switch (item) {
    case PollsWidget():
      return PollsWidget(key: UniqueKey());
    case SvgPicture():
      return SvgPicture.asset(
        key: UniqueKey(),
        'assets/sticker.svg',
      );
    case MusicWidget():
      return item;
    default:
      return const Text('hello');
  }
}

List allWidgetsList = [
  const PollsWidget(),
  SvgPicture.asset(
    'assets/sticker.svg',
    width: 100,
  ),
];

class Song {
  final String link;
  final String title;
  final String thumbnail;
  final String subtitle;

  const Song({
    required this.link,
    required this.title,
    required this.thumbnail,
    required this.subtitle,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'link': String link,
        'title': String title,
        'thumbnail': String thumbnail,
        'subtitle': String subtitle,
      } =>
        Song(
          link: link,
          title: title,
          thumbnail: thumbnail,
          subtitle: subtitle,
        ),
      _ => throw const FormatException('Failed to load Song.'),
    };
  }
}

class PlayingSong with ChangeNotifier {
  String? _song;
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

class VideoDurationModel extends ChangeNotifier {
  int _durationInMilliSeconds = 0;

  int get durationInMilliSeconds => _durationInMilliSeconds;

  void setDurationInMilliSeconds(int seconds) {
    _durationInMilliSeconds = seconds;
    notifyListeners(); // Notify listeners of the change
  }
}

class SelectedProduct extends ChangeNotifier {
  int _productId = 0;

  int get productId => _productId;

  void setProductId(int pId) {
    _productId = pId;
    notifyListeners(); // Notify listeners of the change
  }
}

class TrimmedAudio extends ChangeNotifier {
  String _outputPath = '';

  String get outputPath => _outputPath;

  void setOutputPath(String path) {
    _outputPath = path;
    notifyListeners(); // Notify listeners of the change
  }
}

class ActiveWidget extends ChangeNotifier {
  // ignore: prefer_final_fields
  List<Map<String, dynamic>> _widgets = [];

  List<Map<String, dynamic>> get widgetlist => _widgets;

  void addWidget(Map<String, dynamic> widget) {
    _widgets.add(widget);
    notifyListeners();
  }

  void removeKey({required Key key}) {
    _widgets.removeWhere((element) => element['key'] == key);
    notifyListeners();
  }

  void updatePosition({required Key key, required Matrix4 matrix}) {
    List<num> mat = List<num>.filled(16, 0, growable: false);
    matrix.copyIntoArray(mat);
    _widgets
        .where((element) => element['widget'].key == key)
        .first['position'] = mat;
    notifyListeners();
  }
}

class Product {
  final int id;
  final String name;
  final double price;
  final String image;
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
  });
}

List<Map<String, dynamic>> products = [
  {
    "id": 1,
    "name": "burger",
    "price": 50.50,
    "image": "assets/products/burger-p1.jpg"
  },
  {
    "id": 2,
    "name": "pizza",
    "price": 150.25,
    "image": "assets/products/pizza-p2.jpg"
  },
  {
    "id": 3,
    "name": "waffel",
    "price": 200.30,
    "image": "assets/products/waffel-p3.jpg"
  },
  {
    "id": 4,
    "name": "chai",
    "price": 15,
    "image": "assets/products/chai-p4.jpg"
  },
];

List<Map<String, dynamic>> storyData = [
  {
    'id': '1',
    'video': 'assets/video1.mp4',
    'thumbnail': 'assets/products/chai-p4.jpg',
    'user': {'username': 'Sotoru Gojo', 'profilepic': 'assets/avatar.jpg'},
    'widgets': [
      {
        'widget': const Key('music'),
        'position': List<double>.filled(16, 0),
        'link':
            'https://aac.saavncdn.com/433/5d0773379e72eb85562c91b3b193d4e0_12.mp4',
        'title': 'Shikayat',
        'subtitle': 'AUR(Aurora) Shikayat',
        'thumbnail':
            'https://lh3.googleusercontent.com/6POdzxQK3GVk1MhxMa8KvMCl-9h44-J-9Hj7XJpQf3sfH6NMERuBQhLjD5pDRH0v3g-_H2Qw0emWK9Y=w544-h544-l90-rj',
      },
      {
        'widget': const Key('polls'),
        'position': <double>[
          1.4246864920636282,
          -1.0686063327775563,
          0.0,
          0.0,
          1.0686063327775563,
          1.4246864920636282,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          -363.5059088816478,
          295.83831994799834,
          0.0,
          1.0
        ],
      },
    ],
  },
  {
    'id': '2',
    'video': 'assets/video1.mp4',
    'thumbnail': 'assets/products/pizza-p2.jpg',
    'user': {'username': 'Sotoru Gojo', 'profilepic': 'assets/avatar.jpg'},
    'widgets': [
      {
        'widget': const Key('music'),
        'position': List<double>.filled(16, 0),
        'link':
            'https://aac.saavncdn.com/433/5d0773379e72eb85562c91b3b193d4e0_12.mp4',
        'title': 'Shikayat',
        'subtitle': 'AUR(Aurora) Shikayat',
        'thumbnail':
            'https://lh3.googleusercontent.com/6POdzxQK3GVk1MhxMa8KvMCl-9h44-J-9Hj7XJpQf3sfH6NMERuBQhLjD5pDRH0v3g-_H2Qw0emWK9Y=w544-h544-l90-rj',
      },
      {
        'widget': const Key('polls'),
        'position': <double>[
          1.4246864920636282,
          -1.0686063327775563,
          0.0,
          0.0,
          1.0686063327775563,
          1.4246864920636282,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          -363.5059088816478,
          295.83831994799834,
          0.0,
          1.0
        ],
      },
    ],
  },
  {
    'id': '3',
    'video': 'assets/video1.mp4',
    'thumbnail': 'assets/products/waffel-p3.jpg',
    'user': {'username': 'Sotoru Gojo', 'profilepic': 'assets/avatar.jpg'},
    'widgets': [
      {
        'widget': const Key('music'),
        'position': List<double>.filled(16, 0),
        'link':
            'https://aac.saavncdn.com/433/5d0773379e72eb85562c91b3b193d4e0_12.mp4',
        'title': 'Shikayat',
        'subtitle': 'AUR(Aurora) Shikayat',
        'thumbnail':
            'https://lh3.googleusercontent.com/6POdzxQK3GVk1MhxMa8KvMCl-9h44-J-9Hj7XJpQf3sfH6NMERuBQhLjD5pDRH0v3g-_H2Qw0emWK9Y=w544-h544-l90-rj',
      },
      {
        'widget': const Key('polls'),
        'position': <double>[
          1.4246864920636282,
          -1.0686063327775563,
          0.0,
          0.0,
          1.0686063327775563,
          1.4246864920636282,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          -363.5059088816478,
          295.83831994799834,
          0.0,
          1.0
        ],
      },
    ],
  },
];
// [{widget: SvgPicture-[#09427]("SvgAssetLoader(assets/sticker.svg)", width: 100.0, clipBehavior: hardEdge, colorFilter: "null"), position: [3.8384288755111897, -1.6056475134784047, 0.0, 0.0, 1.6056475134784047, 3.8384288755111897, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, -974.3599786209925, -240.66318736796813, 0.0, 1.0]}, {widget: MusicWidget-[<'Music'>], position: [1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, -59.71540178571428, -107.70145089285717, 0.0, 1.0]}]