import 'package:flutter/widgets.dart';
import '../../core/models/image_layer.dart';
import '../widgets/image_layer_widget.dart';

class ImageRenderer {
  static Widget render(ImageLayer layer) {
    return ImageLayerWidget(layer: layer);
  }
}
