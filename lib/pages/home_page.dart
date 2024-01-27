import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_edit_story/pages/camera_page.dart';
import 'package:flutter_edit_story/pages/story_page.dart';
import 'package:flutter_edit_story/var.dart';

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
