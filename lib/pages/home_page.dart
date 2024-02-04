import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dismissible_page/dismissible_page.dart';
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
  List<Map<String, dynamic>> data = storyData;
  late Future<void> _init;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    var _res = await http.get(
      Uri.https(domain, '/api/story_get'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    var res = jsonDecode(_res.body);
    res.forEach((e) {
      downloadZip(e['file']
          .replaceAll('http', 'https')
          .replaceAll('localhost', domain));
    });
  }

  Future<File> downloadZip(String url) async {
    Directory tempDir = await getTemporaryDirectory();
    Directory dir = Directory('${tempDir.path}/stories');
    dir.create(recursive: true);
    HttpClient client = new HttpClient();
    var _downloadData = <int>[];

    var file = File('${dir.path}/${url.split('/').last}');

    await client.getUrl(Uri.parse(url)).then((HttpClientRequest request) {
      return request.close();
    }).then((HttpClientResponse response) {
      response.listen((d) => _downloadData.addAll(d), onDone: () {
        file
            .writeAsBytes(_downloadData)
            .then((value) async => await _extractZip(file, dir.path));
      });
    });
    return file;
  }

  Future<String> _extractZip(File zipFile, String dir) async {
    print('hello');
    final destinationDir =
        Directory("$dir/${path.basename(zipFile.path).split('.')[0]}");
    print(destinationDir);
    try {
      await ZipFile.extractToDirectory(
          zipFile: zipFile,
          destinationDir: destinationDir,
          onExtracting: (zipEntry, progress) {
            print('progress: ${progress.toStringAsFixed(1)}%');
            print('name: ${zipEntry.name}');
            print('isDirectory: ${zipEntry.isDirectory}');
            print('uncompressedSize: ${zipEntry.uncompressedSize}');
            print('compressedSize: ${zipEntry.compressedSize}');
            print('compressionMethod: ${zipEntry.compressionMethod}');
            print('crc: ${zipEntry.crc}');
            return ZipFileOperation.includeItem;
          });
    } catch (e) {
      print(e);
    }
    return destinationDir.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: data.length,
                physics: AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) => StoryWidget(
                  video: data[index]['video'],
                  image: data[index]['thumbnail'],
                  user: data[index]['user'],
                  widgets: data[index]['widgets'],
                ),
              ),
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
    );
  }
}

class StoryWidget extends StatelessWidget {
  String image;
  String video;
  Map<String, dynamic> user;
  List<Map<String, dynamic>> widgets;
  StoryWidget(
      {super.key,
      required this.video,
      required this.image,
      required this.widgets,
      required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 250,
      padding: const EdgeInsets.all(22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => context.pushTransparentRoute(
                StoryPage(image: image, video: video, widgets: widgets),
              ),
              child: Hero(
                tag: image,
                child: Stack(
                  children: [
                    Image.asset(
                      image,
                      fit: BoxFit.cover,
                      width: 200,
                      height: 250,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          transform: GradientRotation(1.5708),
                          colors: [
                            Colors.black12,
                            Colors.black87,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset(
                            user['profilepic'],
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const Icon(
                          Icons.circle_outlined,
                          color: Color.fromARGB(150, 255, 255, 255),
                          size: 50,
                        )
                      ],
                    ),
                    Text(
                      user['username'],
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
