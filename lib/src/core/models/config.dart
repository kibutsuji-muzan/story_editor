import 'package:flutter/material.dart';

abstract class StoryConfig {
  final String name;
  const StoryConfig({required this.name});
}

class StoryFont extends StoryConfig {
  final TextStyle Function(TextStyle style) styleBuilder;
  final String? textToShow;
  const StoryFont({
    required this.styleBuilder,
    required super.name,
    this.textToShow = 'Aa',
  });
}

class StoryColor extends StoryConfig {
  final Color color;
  const StoryColor({required this.color, required super.name});
}

TextStyle _buildStyle(TextStyle style) => style;

class StoryEditorConfig {
  final List<StoryFont> fonts;
  final List<StoryColor> colors;
  final int maxLayersCount;
  final double minFontSize;
  final double maxFontSize;
  final double minScaleFactor;
  final double maxScaleFactor;

  // Feature Toggles
  final bool enableText;
  final bool enableImage;
  final bool enableSticker;
  final bool enableTimer;
  final bool enablePolls;
  final bool enableMusic;

  const StoryEditorConfig({
    this.fonts = defaultFonts,
    this.colors = defaultColors,
    this.maxLayersCount = 20,
    this.minFontSize = 12.0,
    this.maxFontSize = 100.0,
    this.minScaleFactor = 0.5,
    this.maxScaleFactor = 4.0,
    this.enableText = true,
    this.enableImage = true,
    this.enableSticker = true,
    this.enableTimer = true,
    this.enablePolls = true,
    this.enableMusic = true,
  });

  static StoryEditorConfig _instance = const StoryEditorConfig();

  static StoryEditorConfig get instance => _instance;

  static set instance(StoryEditorConfig config) => _instance = config;

  static const List<StoryColor> defaultColors = [
    StoryColor(name: 'White', color: Colors.white),
    StoryColor(name: 'Black', color: Colors.black),
  ];

  static const List<StoryFont> defaultFonts = [
    StoryFont(name: 'Inter', styleBuilder: _buildStyle),
  ];
}
