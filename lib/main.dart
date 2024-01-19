import 'package:flutter/material.dart';
import 'package:flutter_edit_story/pages/test.dart';
// import 'package:flutter_edit_story/pages/test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_edit_story/var.dart';
import 'package:camera/camera.dart';
import 'package:flutter_edit_story/pages/camera_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayingSong()),
        ChangeNotifierProvider(
          create: (context) => VideoDurationModel(),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade700),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: TestPage(),
      // home: const MusicTestComponent(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      body: SafeArea(
        child: Center(
          child: ElevatedButton(
            onPressed: () async {
              await availableCameras().then(
                (value) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CameraPage(cameras: value),
                  ),
                ),
              );
            },
            child: const Text("Take a Picture"),
          ),
        ),
      ),
    );
  }
}
