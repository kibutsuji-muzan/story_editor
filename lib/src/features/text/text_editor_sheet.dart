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
  final Function? notifyParent;
  final String? data;
  final String? color;
  final String? font;

  const TextEditorSheet({
    super.key,
    this.data,
    this.color,
    this.font,
    this.notifyParent,
  });

  @override
  State<TextEditorSheet> createState() => _TextEditorSheetState();
}

class _TextEditorSheetState extends State<TextEditorSheet> {
  final TextEditingController _txtcontroller = TextEditingController();
  late final CarouselController _carouselController;
  int findex = 0;
  int cindex = 0;

  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    debugPrint(widget.color);
    debugPrint(widget.font);
    if (widget.color != null) {
      final colorIdx = EditorDefaults.defaultColors.indexOf(widget.color!);
      if (colorIdx != -1) {
        cindex = colorIdx;
      }
    }
    if (widget.font != null) {
      final fontIdx = EditorDefaults.defaultFonts.indexOf(widget.font!);
      if (fontIdx != -1) {
        findex = fontIdx;
      }
    }
    _carouselController = CarouselController(initialItem: findex);

    _carouselController.addListener(() {
      final offsetChunck = context.screenWidth / 7;
      final index = _carouselController.offset / offsetChunck;
      setState(() => findex = index.round());
    });

    _txtcontroller.text = widget.data ?? '';
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _txtcontroller.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fonts = EditorDefaults.defaultFonts;
    final colors = EditorDefaults.defaultColors;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // SizedBox(
            //   width: MediaQuery.of(context).size.width,
            //   height: MediaQuery.of(context).size.height * 0.05,
            //   child: WheelChooser.custom(
            //     startPosition: 0,
            //     onValueChanged: (s) => setState(() => cindex = s),
            //     horizontal: true,
            //     perspective: 0.00000001,
            //     children: List.generate(
            //       colors.length,
            //       (indx) => Stack(
            //         alignment: Alignment.center,
            //         children: [
            //           Container(
            //             height: MediaQuery.of(context).size.width * 0.07,
            //             width: MediaQuery.of(context).size.width * 0.07,
            //             decoration: BoxDecoration(
            //               color: (indx == cindex)
            //                   ? Colors.white54
            //                   : Colors.black12,
            //               borderRadius: BorderRadius.circular(100),
            //             ),
            //           ),
            //           Container(
            //             height: MediaQuery.of(context).size.width * 0.06,
            //             width: MediaQuery.of(context).size.width * 0.06,
            //             decoration: BoxDecoration(
            //               // color: (colors[indx])),
            //               borderRadius: BorderRadius.circular(100),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            TextField(
              focusNode: focusNode,
              autofocus: true,
              maxLines: null,
              style: TextStyle(
                fontSize: 30,
                // color: (colors[cindex])),
                fontFamily: fonts[findex],
                package: 'story_editor',
                decoration: TextDecoration.none,
                decorationColor: const Color.fromRGBO(0, 0, 0, 0),
                // decorationStyle: TextDecorationStyle.wavy,
              ),
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
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.05,
              ),
              child: CarouselView.weighted(
                controller: _carouselController,
                flexWeights: const <int>[1, 1, 2, 1, 1, 1],
                itemSnapping: true,
                onTap: (value) {
                  setState(() => findex = value);
                  _carouselController.animateToItem(value);
                },
                children: fonts
                    .map(
                      (font) => Center(
                        child: Text(
                          'Aa',
                          style: TextStyle(
                            fontSize: (fonts.indexOf(font) == findex) ? 22 : 20,
                            color: (fonts.indexOf(font) == findex)
                                ? Colors.black
                                : Colors.black87,
                            fontFamily: font,
                            package: 'story_editor',
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
