import 'package:flutter/material.dart';
import 'package:story_editor/src/widgets/trash_can.dart';
import 'package:story_editor/story_editor.dart';

class StoryEditor extends StatelessWidget {
  final StoryEditorController controller;
  final StoryEditorConfig? config;
  final PluginRegistry? pluginRegistry;
  final VoidCallback? onTapText;
  final VoidCallback? onTapStickers;
  final VoidCallback? onTapMusic;
  final VoidCallback? onTapProduct;
  final bool isAudioMuted;
  final VoidCallback? onToggleAudio;
  final VoidCallback? onTapClose;

  const StoryEditor({
    super.key,
    required this.controller,
    this.config,
    this.pluginRegistry,
    this.onTapText,
    this.onTapStickers,
    this.onTapMusic,
    this.onTapProduct,
    this.isAudioMuted = false,
    this.onToggleAudio,
    this.onTapClose,
  });

  @override
  Widget build(BuildContext context) {
    if (config != null) {
      StoryEditorConfig.instance = config!;
    }
    final activeRegistry = pluginRegistry ?? PluginRegistry.instance;

    return StoryEditorScope(
      notifier: controller,
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0),
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // Main Canvas
              StoryCanvas(pluginRegistry: pluginRegistry),

              // Floating Toolbar at Top Center
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: EditorToolbar(onTapClose: onTapClose),
              ),
              TrashCan(),
              // Product Tag Indicator at Bottom Left
              // Consumer<StoryEditorController>(
              //   builder: (context, controller, child) {
              //     final productId = controller.state.taggedProductId;
              //     if (productId == 0) return const SizedBox();
              //     return Positioned(
              //       bottom: 20,
              //       left: 20,
              //       child: Container(
              //         padding: const EdgeInsets.symmetric(
              //           horizontal: 12,
              //           vertical: 6,
              //         ),
              //         decoration: BoxDecoration(
              //           color: Colors.black54,
              //           borderRadius: BorderRadius.circular(15),
              //           border: Border.all(color: Colors.white24),
              //         ),
              //         child: Row(
              //           children: [
              //             const Icon(
              //               Icons.shopping_bag_rounded,
              //               color: Colors.greenAccent,
              //               size: 16,
              //             ),
              //             const SizedBox(width: 6),
              //             Text(
              //               'Tagged: #$productId',
              //               style: const TextStyle(
              //                 color: Colors.white,
              //                 fontSize: 12,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class StoryEditorScope extends InheritedNotifier<StoryEditorController> {
  const StoryEditorScope({
    super.key,
    required StoryEditorController super.notifier,
    required super.child,
  });

  static StoryEditorController of(BuildContext context, {bool listen = true}) {
    if (listen) {
      final scope = context
          .dependOnInheritedWidgetOfExactType<StoryEditorScope>();
      assert(scope != null, 'No StoryEditorScope found in context');
      return scope!.notifier!;
    } else {
      final element = context
          .getElementForInheritedWidgetOfExactType<StoryEditorScope>();
      assert(element != null, 'No StoryEditorScope found in context');
      return (element!.widget as StoryEditorScope).notifier!;
    }
  }
}
