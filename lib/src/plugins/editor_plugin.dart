import 'package:flutter/widgets.dart';
import '../core/controllers/story_editor_controller.dart';

abstract class EditorPlugin {
  final String id;
  final String name;
  final IconData icon;

  const EditorPlugin({
    required this.id,
    required this.name,
    required this.icon,
  });

  void onTap(BuildContext context, StoryEditorController controller);
}
