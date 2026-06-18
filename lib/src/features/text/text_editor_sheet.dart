import 'package:flutter/material.dart';
import 'package:story_editor/story_editor.dart';
// src/
// └── features/
//     └── text/
//         ├── text_layer.dart
//         ├── text_layer_widget.dart
//         ├── text_editor_sheet.dart
//         ├── text_style_picker.dart
//         ├── text_toolbar_action.dart
//         └── text_plugin.dart

class TextEditorSheet extends StatefulWidget {
  final StoryEditorController controller;
  final TextLayer? existingLayer;

  const TextEditorSheet({
    super.key,
    required this.controller,
    this.existingLayer,
  });

  @override
  State<TextEditorSheet> createState() => _TextEditorSheetState();
}

class _TextEditorSheetState extends State<TextEditorSheet> {
  final TextEditingController _txtcontroller = TextEditingController();
  late final CarouselController _fontcarouselController;
  late final CarouselController _colorcarouselController;
  int findex = 0;
  int cindex = 0;

  FocusNode focusNode = FocusNode();
  late final String _layerId;
  late final bool _isNewLayer;

  @override
  void initState() {
    super.initState();
    _isNewLayer = widget.existingLayer == null;
    _layerId = widget.existingLayer?.id ?? LayerUtils.generateUniqueId('text');

    if (!_isNewLayer) {
      final existing = widget.existingLayer!;
      final colorIdx = TextEditorsChoices.colors.indexWhere((c) => c.color.value == existing.color.value);
      if (colorIdx != -1) {
        cindex = colorIdx;
      }
      final fontIdx = TextEditorsChoices.fonts.indexWhere((f) => f.name == existing.fontFamily);
      if (fontIdx != -1) {
        findex = fontIdx;
      }
      _txtcontroller.text = existing.text;
    } else {
      _txtcontroller.text = '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.controller.addLayerWithoutHistory(
            TextLayer(
              id: _layerId,
              text: '',
              color: TextEditorsChoices.colors[cindex].color,
              fontFamily: TextEditorsChoices.fonts[findex].name,
            ),
          );
        }
      });
    }

    _fontcarouselController = CarouselController(initialItem: findex);
    _colorcarouselController = CarouselController(initialItem: cindex);

    _fontcarouselController.addListener(() {
      final offsetChunck = context.screenWidth / 7;
      final index = _fontcarouselController.offset / offsetChunck;
      if (TextEditorsChoices.fonts.isNotEmpty) {
        final newIndex = index.round().clamp(
          0,
          TextEditorsChoices.fonts.length - 1,
        );
        if (newIndex != findex) {
          setState(() {
            findex = newIndex;
            _updateLayer();
          });
        }
      }
    });
    _colorcarouselController.addListener(() {
      final offsetChunck = context.screenWidth / 7;
      final index = _colorcarouselController.offset / offsetChunck;
      if (TextEditorsChoices.colors.isNotEmpty) {
        final newIndex = index.round().clamp(
          0,
          TextEditorsChoices.colors.length - 1,
        );
        if (newIndex != cindex) {
          setState(() {
            cindex = newIndex;
            _updateLayer();
          });
        }
      }
    });

    _txtcontroller.addListener(_updateLayer);

    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        if (mounted) {
          final route = ModalRoute.of(context);
          if (route != null && route.isCurrent) {
            Navigator.of(context).pop();
          }
        }
      }
    });
  }

  void _updateLayer() {
    final currentLayers = widget.controller.layers;
    final index = currentLayers.indexWhere((l) => l.id == _layerId);
    if (index != -1) {
      final layer = currentLayers[index] as TextLayer;
      widget.controller.updateLayerWithoutHistory(
        layer.copyWith(
          text: _txtcontroller.text,
          color: TextEditorsChoices.colors[cindex].color,
          fontFamily: TextEditorsChoices.fonts[findex].name,
        ),
      );
    } else if (_isNewLayer) {
      widget.controller.addLayerWithoutHistory(
        TextLayer(
          id: _layerId,
          text: _txtcontroller.text,
          color: TextEditorsChoices.colors[cindex].color,
          fontFamily: TextEditorsChoices.fonts[findex].name,
        ),
      );
    }
  }

  @override
  void dispose() {
    _txtcontroller.removeListener(_updateLayer);
    _txtcontroller.dispose();
    _fontcarouselController.dispose();
    _colorcarouselController.dispose();
    focusNode.dispose();

    final text = _txtcontroller.text.trim();
    if (text.isEmpty) {
      widget.controller.removeLayer(_layerId);
    } else {
      widget.controller.commitTransformHistory();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fonts = TextEditorsChoices.fonts;
    final colors = TextEditorsChoices.colors;

    final fontName = fonts.isNotEmpty ? fonts[findex].name : '';
    final storyFont = StoryEditorConfig.instance.fonts.firstWhere(
      (f) => f.name == fontName,
      orElse: () => StoryFont(
        name: fontName,
        styleBuilder: (style) => style.copyWith(fontFamily: fontName),
      ),
    );
    final baseStyle = TextStyle(
      fontSize: 30,
      color: colors.isNotEmpty ? colors[cindex].color : Colors.white,
      decoration: TextDecoration.none,
      decorationColor: const Color.fromRGBO(0, 0, 0, 0),
    );
    final textFieldStyle = storyFont.styleBuilder(baseStyle);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.05,
              ),
              child: CarouselView.weighted(
                controller: _colorcarouselController,
                flexWeights: const <int>[1, 1, 2, 1, 1, 1],
                itemSnapping: true,
                onTap: (value) {
                  setState(() => cindex = value);
                  _colorcarouselController.animateToItem(value);
                },
                children: colors
                    .map(
                      (e) => DecoratedBox(
                        decoration: BoxDecoration(
                          color: e.color,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: Colors.white,
                            width: colors[cindex].name == e.name ? 2 : 0,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            Hero(
              tag: _layerId,
              child: Material(
                color: Colors.transparent,
                child: TextField(
                  focusNode: focusNode,
                  autofocus: true,
                  maxLines: null,
                  style: textFieldStyle,
                  keyboardType: TextInputType.text,
                  onSubmitted: (value) {},
                  textAlign: TextAlign.center,
                  controller: _txtcontroller,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromRGBO(0, 0, 0, 0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(style: BorderStyle.none),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(style: BorderStyle.none),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.05,
              ),
              child: CarouselView.weighted(
                controller: _fontcarouselController,
                flexWeights: const <int>[1, 1, 2, 1, 1, 1],
                itemSnapping: true,
                onTap: (value) {
                  setState(() => findex = value);
                  _fontcarouselController.animateToItem(value);
                },
                children: fonts.map((font) {
                  final isSelected = fonts.indexOf(font) == findex;
                  final fontStoryFont = StoryEditorConfig.instance.fonts
                      .firstWhere(
                        (f) => f.name == font.name,
                        orElse: () => StoryFont(
                          name: font.name,
                          styleBuilder: (style) =>
                              style.copyWith(fontFamily: font.name),
                        ),
                      );
                  final basePreviewStyle = TextStyle(
                    fontSize: isSelected ? 22 : 20,
                    color: isSelected ? Colors.black : Colors.black87,
                  );
                  return Center(
                    child: Text(
                      'Aa',
                      style: fontStoryFont.styleBuilder(basePreviewStyle),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
