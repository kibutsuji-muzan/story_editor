import 'package:flutter/material.dart';
import 'package:story_editor/story_editor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final StoryEditorController _controller = StoryEditorController(
    initialState: EditorState(
      backgroundPath: 'assets/chai-p4.jpg',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return StoryEditor(
      onTapText: () {
        _controller.addLayer(TextLayer(id: '1', text: 'Hello'));
      },
      onTapStickers: () {
        _controller.addLayer(
          StickerLayer(
            id: '2',
            url:
                'https://i.giphy.com/media/v1.Y2lkPTc5MGI3NjExM3ZtMnU1cnRxOHMxaDFmd243MHhpb3BqMnloam1wNjRsZmg5c21qMyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9cw/l0Exhc7S4E5Z6Hj4k/giphy.gif',
          ),
        );
      },
      controller: _controller,
    );
  }
}
