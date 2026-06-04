import 'package:flutter/widgets.dart';
import '../../features/text/text_layer.dart';
import '../../features/text/text_layer_widget.dart';

class TextRenderer {
  static Widget render(TextLayer layer) {
    return TextLayerWidget(layer: layer);
  }
}
