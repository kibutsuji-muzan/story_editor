import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_edit_story/pages/camera_page.dart';
import 'package:flutter_edit_story/pages/story_page.dart';
import 'package:flutter_edit_story/var.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> storyDir = [];

  @override
  void initState() {
    super.initState();
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    var _res = await http.get(
      Uri.https(domain, '/api/story_get'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    var res = jsonDecode(_res.body);
    List<Map<String, dynamic>> result = [];
    int i = 0;
    for (Map<String, dynamic> r in res) {
      await downloadZip(r['file']
              .replaceAll('http', 'https')
              .replaceAll('localhost', domain))
          .then((value) {
        result.add({
          'productId': res[i]['product_id'],
          'username': res[i]['user_id'],
          'directory':
              '${value.dir.path}/${value.file.path.split('/').last.split('.').first}',
        });
        i++;
      });
    }
    return result;
  }

  Future<({File file, Directory dir})> downloadZip(String url) async {
    Directory tempDir = await getTemporaryDirectory();
    Directory dir = Directory('${tempDir.path}/stories')
      ..create(recursive: true);
    HttpClient client = HttpClient();
    var downloadData = <int>[];

    var file = File('${dir.path}/${url.split('/').last}');

    var b = await client.getUrl(Uri.parse(url)).then((value) => value.close())
      ..listen(
        (event) => downloadData.addAll(event),
        onDone: () async {
          await file
              .writeAsBytes(downloadData)
              .then((value) => _extractZip(value, dir.path));
        },
      );
    return (file: file, dir: dir);
  }

  Future<String> _extractZip(File zipFile, String dir) async {
    final destinationDir =
        Directory("$dir/${path.basename(zipFile.path).split('.')[0]}");
    try {
      await ZipFile.extractToDirectory(
          zipFile: zipFile,
          destinationDir: destinationDir,
          onExtracting: (zipEntry, progress) {
            return ZipFileOperation.includeItem;
          }).then((value) {
        zipFile.delete();
      });
    } catch (e) {
      debugPrint('$e');
    }
    return destinationDir.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        title: const Text('Story Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 22.0, top: 22),
        child: SafeArea(
          child: Stack(
            children: [
              FutureBuilder(
                future: fetchData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No Story Posted Yet'),
                    );
                  }
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: snapshot.data!.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) => StoryWidget(
                      productId: snapshot.data?[index]['productId'],
                      userName: snapshot.data?[index]['username'],
                      dir: snapshot.data?[index]['directory'],
                    ),
                  );
                },
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CameraPage(),
                      ),
                    ),
                    icon: const Icon(Icons.camera),
                    label: const Text('Add Story'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class StoryWidget extends StatefulWidget {
  String userName;
  int? productId;
  String dir;
  StoryWidget({
    super.key,
    required this.productId,
    required this.userName,
    required this.dir,
  });

  @override
  State<StoryWidget> createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    animation = Tween<double>(begin: 0, end: 1).animate(controller);
    controller.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryPage(
              userName: widget.userName,
              productId: widget.productId,
              dir: widget.dir,
            ),
          ),
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    'assets/avatar.jpg',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) => CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue,
                    value: animation.value,
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.userName),
            ),
          ],
        ),
      ),
    );
  }
}

// class StoryWidget extends StatelessWidget {
//   String image;
//   String video;
//   Map<String, dynamic> user;
//   List<Map<String, dynamic>> widgets;
//   StoryWidget(
//       {super.key,
//       required this.video,
//       required this.image,
//       required this.widgets,
//       required this.user});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 200,
//       height: 250,
//       padding: const EdgeInsets.all(22),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(15),
//         child: Stack(
//           children: [
//             GestureDetector(
//               onTap: () => context.pushTransparentRoute(
//                 StoryPage(image: image, video: video, widgets: widgets),
//               ),
//               child: Hero(
//                 tag: image,
//                 child: Stack(
//                   children: [
//                     Image.asset(
//                       image,
//                       fit: BoxFit.cover,
//                       width: 200,
//                       height: 250,
//                     ),
//                     Container(
//                       decoration: const BoxDecoration(
//                         gradient: LinearGradient(
//                           transform: GradientRotation(1.5708),
//                           colors: [
//                             Colors.black12,
//                             Colors.black87,
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(10),
//               child: Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(100),
//                           child: Image.asset(
//                             user['profilepic'],
//                             width: 40,
//                             height: 40,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         const Icon(
//                           Icons.circle_outlined,
//                           color: Color.fromARGB(150, 255, 255, 255),
//                           size: 50,
//                         )
//                       ],
//                     ),
//                     Text(
//                       user['username'],
//                       style: const TextStyle(color: Colors.white),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
