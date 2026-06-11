import 'package:flutter/material.dart';
import 'package:story_editor/extensions/context_extensions.dart';

class TextStylePicker extends StatefulWidget {
  final List<String> list;
  final Widget child;
  const TextStylePicker({super.key, required this.list, required this.child});

  @override
  State<TextStylePicker> createState() => _TextStylePickerState();
}

class _TextStylePickerState extends State<TextStylePicker> {
  late CarouselController _carouselController;
  int index = 0;

  @override
  void initState() {
    super.initState();
    _carouselController = CarouselController(initialItem: index);
    _carouselController.addListener(() {
      final offsetChunck = context.screenWidth / 7;
      final index = _carouselController.offset / offsetChunck;
      if (widget.list.isNotEmpty) {
        final newIndex = index.round().clamp(0, widget.list.length - 1);
        if (newIndex != this.index) {
          setState(() => this.index = newIndex);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.05,
      ),
      child: CarouselView.weighted(
        controller: _carouselController,
        flexWeights: const <int>[1, 1, 2, 1, 1, 1],
        itemSnapping: true,
        onTap: (value) {
          setState(() => index = value);
          _carouselController.animateToItem(value);
        },
        children: widget.list
            .map(
              (font) => Center(
                child: Text(
                  'Aa',
                  style: TextStyle(
                    fontSize: (widget.list.indexOf(font) == index) ? 22 : 20,
                    color: (widget.list.indexOf(font) == index)
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
    );
  }
}
