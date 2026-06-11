import 'package:story_editor/src/core/models/config.dart';

class TextEditorsChoices {
  static List<StoryFont> get fonts => StoryEditorConfig.instance.fonts;

  static List<StoryColor> get colors => StoryEditorConfig.instance.colors;
}
