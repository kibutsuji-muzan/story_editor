import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_edit_story/var.dart';
import 'package:flutter_edit_story/widgets/TimerWidget.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ScrollModal extends StatefulWidget {
  Function notifyParent;
  ScrollModal({super.key, required this.notifyParent});

  @override
  State<StatefulWidget> createState() => _ScrollModalState();
}

class _ScrollModalState extends State<ScrollModal>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late TabController _tcon;
  String gif = '';
  String sticker = '';
  String gif2 = '';

  @override
  void initState() {
    _tcon = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 0.9,
      minChildSize: 0.5,
      initialChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          margin: const EdgeInsets.only(top: 50),
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadiusDirectional.vertical(
              top: Radius.circular(30),
            ),
          ),
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
                  onSubmitted: (value) {
                    print(_tcon.index);
                    if (_tcon.index == 0) {
                      setState(() => gif = value);
                    } else if (_tcon.index == 1) {
                      setState(() => sticker = value);
                    } else {
                      debugPrint('object');
                    }
                  },
                  onChanged: (value) {
                    print(value);
                    if (value.isEmpty) {
                      setState(() => gif = '');
                      setState(() => sticker = '');
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
                child: Scaffold(
                  appBar: TabBar(
                    controller: _tcon,
                    tabs: const [
                      Icon(Icons.gif_outlined),
                      Icon(Icons.sticky_note_2_rounded),
                      Icon(Icons.widgets),
                    ],
                  ),
                  body: TabBarView(
                    controller: _tcon,
                    children: [
                      GifTabBar(controller: scrollController, query: gif),
                      StickerTabBar(
                          controller: scrollController, query: sticker),
                      WidgetTabBar(controller: scrollController),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class GifTabBar extends StatefulWidget {
  ScrollController controller;
  String query;
  GifTabBar({super.key, required this.controller, required this.query});

  @override
  State<GifTabBar> createState() => _GifTabBarState();
}

class _GifTabBarState extends State<GifTabBar> {
  late Future<List<String>> gifs = get_data();
  List<String> searched = [];

  Future<List<String>> get_data() async {
    List<String> a = [];
    if (widget.query.isEmpty) {
      setState(() => searched.clear());
    }
    var res = await http.get(
      Uri.https('api.giphy.com', '/v1/gifs/trending', {
        'api_key': 'bgyDOqflR3ONHtr55eT3yV41Q8LsEQ57',
      }),
    );
    for (Map slug in jsonDecode(res.body)['data']) {
      a.add(slug['id']);
    }
    return a;
  }

  Future<List<String>> search_gif(String query) async {
    List<String> a = [];
    var res = await http.get(
      Uri.https('api.giphy.com', '/v1/gifs/search', {
        'api_key': 'bgyDOqflR3ONHtr55eT3yV41Q8LsEQ57',
        'q': query,
      }),
    );
    print('search');
    for (Map slug in jsonDecode(res.body)['data']) {
      setState(() => searched.add(slug['id']));
    }
    return a;
  }

  @override
  void dispose() {
    widget.query = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: (widget.query.isEmpty) ? get_data() : search_gif(widget.query),
      builder: (context, snapshot) => snapshot.hasData
          ? SingleChildScrollView(
              controller: widget.controller,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    searched.isEmpty ? snapshot.data!.length : searched.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      Provider.of<ActiveWidget>(context, listen: false)
                          .addWidget({
                        'widget': const Key('gif'),
                        'key': UniqueKey(),
                        'link':
                            'https://i.giphy.com/${searched.isEmpty ? snapshot.data![index] : searched[index]}.webp'
                      });
                    },
                    child: GridTile(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Image.network(
                            'https://i.giphy.com/${searched.isEmpty ? snapshot.data![index] : searched[index]}.webp',
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1,
                    vertical: MediaQuery.of(context).size.height * 0.1),
                width: MediaQuery.of(context).size.width * 0.1,
                height: MediaQuery.of(context).size.width * 0.1,
                child: const CircularProgressIndicator(),
              ),
            ),
    );
  }
}

class StickerTabBar extends StatefulWidget {
  String query;
  ScrollController controller;
  StickerTabBar({super.key, required this.controller, required this.query});

  @override
  State<StickerTabBar> createState() => _StickerTabBarState();
}

class _StickerTabBarState extends State<StickerTabBar> {
  late Future<List<String>> gifs = get_data();
  List<String> searched = [];

  Future<List<String>> get_data() async {
    List<String> a = [];
    if (widget.query.isEmpty) {
      setState(() => searched.clear());
    }
    var res = await http.get(
      Uri.https('api.giphy.com', 'v1/stickers/trending', {
        'api_key': 'bgyDOqflR3ONHtr55eT3yV41Q8LsEQ57',
      }),
    );
    for (Map slug in jsonDecode(res.body)['data']) {
      a.add(slug['id']);
    }
    return a;
  }

  Future<List<String>> search_sticker(String query) async {
    List<String> a = [];
    if (widget.query.isEmpty) {
      setState(() => searched.clear());
    }
    var res = await http.get(
      Uri.https('api.giphy.com', '/v1/stickers/search', {
        'api_key': 'bgyDOqflR3ONHtr55eT3yV41Q8LsEQ57',
        'q': query,
      }),
    );
    for (Map slug in jsonDecode(res.body)['data']) {
      setState(() => searched.add(slug['id']));
    }
    return a;
  }

  @override
  void dispose() {
    widget.query = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          (widget.query.isEmpty) ? get_data() : search_sticker(widget.query),
      builder: (context, snapshot) => snapshot.hasData
          ? SingleChildScrollView(
              controller: widget.controller,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    searched.isEmpty ? snapshot.data!.length : searched.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      print('object');
                      Provider.of<ActiveWidget>(context, listen: false)
                          .addWidget({
                        'widget': const Key('sticker'),
                        'key': UniqueKey(),
                        'link':
                            'https://i.giphy.com/${searched.isEmpty ? snapshot.data![index] : searched[index]}.webp'
                      });
                      setState(() {});

                      // widget.notifyParent(searched.isEmpty
                      //     ? snapshot.data![index]
                      //     : searched);
                      // Navigator.of(context).pop(context);
                    },
                    child: GridTile(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Image.network(
                              'https://i.giphy.com/${searched.isEmpty ? snapshot.data![index] : searched[index]}.webp'),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1,
                    vertical: MediaQuery.of(context).size.height * 0.1),
                width: MediaQuery.of(context).size.width * 0.1,
                height: MediaQuery.of(context).size.width * 0.1,
                child: const CircularProgressIndicator(),
              ),
            ),
    );
  }
}

class WidgetTabBar extends StatefulWidget {
  ScrollController controller;
  WidgetTabBar({super.key, required this.controller});

  @override
  State<WidgetTabBar> createState() => _WidgetTabBarState();
}

class _WidgetTabBarState extends State<WidgetTabBar> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisSpacing: 1,
      mainAxisSpacing: 2,
      crossAxisCount: 2,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: _Timer(),
          ),
        ),
      ],
    );
  }

  Widget _Timer() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
          isScrollControlled: true,
          builder: (context) => const TimerModal(),
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              blurRadius: 2,
            )
          ],
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Timer \nWidget',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
