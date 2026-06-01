import 'package:flutter/widgets.dart';
import '../../core/models/text_layer.dart';
import '../widgets/text_layer_widget.dart';

class TextRenderer {
  static Widget render(TextLayer layer) {
    return TextLayerWidget(layer: layer);
  }
}
