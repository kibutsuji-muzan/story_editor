import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_edit_story/pages/home_page.dart';
import 'package:flutter_edit_story/pages/test_copy.dart';
import 'package:flutter_edit_story/widgets/TimerWidget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_edit_story/var.dart';

import 'pages/video_edit_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayingSong()),
        ChangeNotifierProvider(create: (_) => StoryList()),
        ChangeNotifierProvider(create: (_) => VideoDurationModel()),
        ChangeNotifierProvider(create: (_) => TrimmedAudio()),
        ChangeNotifierProvider(create: (_) => SelectedProduct()),
        ChangeNotifierProvider(create: (_) => ActiveWidget()),
        ChangeNotifierProvider(create: (_) => DurationTimer())
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
      // home: const HomePage(),
      // home: TimerWidget(),
      home: VideoEditPage(
        file: XFile('assets/video.mp4'),
        video: true,
      ),
    );
  }
}

extension HexToColor on String {
  Color get hextocolor {
    final hexString = this;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
// [1.4246864920636282, -1.0686063327775563, 0.0, 0.0, 1.0686063327775563, 1.4246864920636282, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, -363.5059088816478, 295.83831994799834, 0.0, 1.0]