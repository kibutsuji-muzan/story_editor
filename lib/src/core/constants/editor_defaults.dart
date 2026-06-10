import 'package:story_editor/src/core/models/config.dart';
import 'package:flutter/material.dart';

class TextEditorsChoices {
  static List<String> get fonts =>
      StoryEditorConfig.instance.fonts.map((f) => f.name).toList();

  static List<String> get colors =>
      StoryEditorConfig.instance.colors.map((c) => _colorToHex(c.color)).toList();

  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}
