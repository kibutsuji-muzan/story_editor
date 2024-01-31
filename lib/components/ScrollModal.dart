import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_edit_story/var.dart';
import 'package:http/http.dart' as http;

class ScrollModal extends StatefulWidget {
  Function notifyParent;
  ScrollModal({super.key, required this.notifyParent});

  @override
  State<StatefulWidget> createState() => _ScrollModalState();
}

class _ScrollModalState extends State<ScrollModal> {
  late Future<List<String>> gifs = get_data();
  final TextEditingController _controller = TextEditingController();
  List<String> searched = [];
  @override
  void initState() {
    get_data();
    super.initState();
  }

// https://i.giphy.com/6CAFIoo26LkJxjk3Gc.webp
  Future<List<String>> get_data() async {
    List<String> a = [];
    int _count = 0;
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

  void search_gif(String query) async {
    var res = await http.get(
      Uri.https('api.giphy.com', '/v1/gifs/search', {
        'api_key': 'bgyDOqflR3ONHtr55eT3yV41Q8LsEQ57',
        'q': query,
      }),
    );
    for (Map slug in jsonDecode(res.body)['data']) {
      print(slug['id']);
      setState(() => searched.add(slug['id']));
    }
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
                    onSubmitted: (value) {
                      search_gif(value);
                    },
                    onChanged: (value) async {
                      if (value == '') {
                        setState(() => searched = []);
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
                FutureBuilder(
                  future: get_data(),
                  builder: (context, snapshot) => snapshot.hasData
                      ? Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  spreadRadius: 5,
                                  offset: Offset(0, 5),
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: GridView.builder(
                                    semanticChildCount: 4,
                                    shrinkWrap: true,
                                    controller: scrollController,
                                    itemCount: searched.isEmpty
                                        ? snapshot.data!.length
                                        : searched.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                    ),
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          widget.notifyParent(searched.isEmpty
                                              ? snapshot.data![index]
                                              : searched);
                                          Navigator.of(context).pop(context);
                                        },
                                        child: GridTile(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0),
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
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.2,
                              vertical:
                                  MediaQuery.of(context).size.height * 0.2),
                          width: MediaQuery.of(context).size.width * 0.1,
                          height: MediaQuery.of(context).size.width * 0.1,
                          child: const CircularProgressIndicator(),
                        ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
