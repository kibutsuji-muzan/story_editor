import 'package:flutter/widgets.dart';
import '../../core/models/editor_layer.dart';
import '../../core/models/text_layer.dart';
import '../../core/models/image_layer.dart';
import '../../core/models/sticker_layer.dart';
import '../widgets/text_layer_widget.dart';
import '../widgets/image_layer_widget.dart';
import '../widgets/sticker_layer_widget.dart';

class LayerRenderer {
  static Widget render(EditorLayer layer) {
    if (layer is TextLayer) {
      return TextLayerWidget(layer: layer);
    } else if (layer is ImageLayer) {
      return ImageLayerWidget(layer: layer);
    } else if (layer is StickerLayer) {
      return StickerLayerWidget(layer: layer);
    }
    return const SizedBox();
  }
}
