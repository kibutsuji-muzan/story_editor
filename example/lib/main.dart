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
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
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
    initialState: const EditorState(
      background: AssetMediaSource('assets/img.jpg', type: MediaType.image),
    ),
  );
  @override
  void initState() {
    StoryEditorConfig.instance = StoryEditorConfig(
      colors: defaultColors,
      fonts: defaultFonts,
    );
    super.initState();
  }

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

TextStyle _buildInterStyle(TextStyle style) =>
    style.copyWith(fontFamily: 'Inter');
TextStyle _buildAbrilFatfaceStyle(TextStyle style) =>
    style.copyWith(fontFamily: 'AbrilFatface');
TextStyle _buildBebasNeueStyle(TextStyle style) =>
    style.copyWith(fontFamily: 'BebasNeue');
TextStyle _buildDancingScriptStyle(TextStyle style) =>
    style.copyWith(fontFamily: 'DancingScript');
TextStyle _buildKolkerBrushStyle(TextStyle style) =>
    style.copyWith(fontFamily: 'KolkerBrush');
TextStyle _buildProtestRevolutionStyle(TextStyle style) =>
    style.copyWith(fontFamily: 'ProtestRevolution');
TextStyle _buildProtestStrikeStyle(TextStyle style) =>
    style.copyWith(fontFamily: 'ProtestStrike');
TextStyle _buildRubikDoodleShadowStyle(TextStyle style) =>
    style.copyWith(fontFamily: 'RubikDoodleShadow');
TextStyle _buildRubikGlitchPopStyle(TextStyle style) =>
    style.copyWith(fontFamily: 'RubikGlitchPop');
TextStyle _buildZenTokyoZooStyle(TextStyle style) =>
    style.copyWith(fontFamily: 'ZenTokyoZoo');

const List<StoryColor> defaultColors = [
  StoryColor(name: 'White', color: Colors.white),
  StoryColor(name: 'Black', color: Colors.black),
  StoryColor(name: 'Red', color: Color.fromARGB(255, 255, 75, 75)),
  StoryColor(name: 'Orange', color: Color.fromARGB(255, 255, 159, 67)),
  StoryColor(name: 'Yellow', color: Color.fromARGB(255, 255, 225, 64)),
  StoryColor(name: 'Green', color: Color.fromARGB(255, 43, 236, 106)),
  StoryColor(name: 'Teal', color: Color.fromARGB(255, 0, 210, 211)),
  StoryColor(name: 'Blue', color: Color.fromARGB(255, 84, 160, 255)),
  StoryColor(name: 'Indigo', color: Color.fromARGB(255, 95, 39, 205)),
  StoryColor(name: 'Purple', color: Color.fromARGB(255, 140, 54, 255)),
  StoryColor(name: 'Pink', color: Color.fromARGB(255, 255, 82, 82)),
];

const List<StoryFont> defaultFonts = [
  StoryFont(name: 'Inter', styleBuilder: _buildInterStyle),
  StoryFont(name: 'AbrilFatface', styleBuilder: _buildAbrilFatfaceStyle),
  StoryFont(name: 'BebasNeue', styleBuilder: _buildBebasNeueStyle),
  StoryFont(name: 'DancingScript', styleBuilder: _buildDancingScriptStyle),
  StoryFont(name: 'KolkerBrush', styleBuilder: _buildKolkerBrushStyle),
  StoryFont(
    name: 'ProtestRevolution',
    styleBuilder: _buildProtestRevolutionStyle,
  ),
  StoryFont(
    name: 'ProtestStrike',
    styleBuilder: _buildProtestStrikeStyle,
    textToShow: 'ProtestStrike',
  ),
  StoryFont(
    name: 'RubikDoodleShadow',
    styleBuilder: _buildRubikDoodleShadowStyle,
  ),
  StoryFont(name: 'RubikGlitchPop', styleBuilder: _buildRubikGlitchPopStyle),
  StoryFont(name: 'ZenTokyoZoo', styleBuilder: _buildZenTokyoZooStyle),
];
