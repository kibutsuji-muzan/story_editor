import 'package:flutter/widgets.dart';
import '../../features/image/image_layer.dart';
import '../../features/image/image_layer_widget.dart';

class ImageRenderer {
  static Widget render(ImageLayer layer) {
    return ImageLayerWidget(layer: layer);
  }
}
