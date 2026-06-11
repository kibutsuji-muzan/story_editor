import 'package:flutter/material.dart';
import 'package:story_editor/extensions/matrix_extension.dart';
import 'package:story_editor/src/editor/story_editor.dart';
import 'package:story_editor/story_editor.dart';

class TrashCan extends StatefulWidget {
  const TrashCan({super.key});

  @override
  State<TrashCan> createState() => _TrashCanState();
}

class _TrashCanState extends State<TrashCan> {
  double? distance;

  _calculateDistance(StoryEditorController controller) {
    if (!controller.hasSelection) return;
    final trashCenter = Offset(0, (context.screenHeight / 2) - 50);
    print("trashCenter: $trashCenter");
    print("widgetOffset: ${controller.selectedLayer!.transform.matrix.offset}");
    setState(
      () => distance =
          (controller.selectedLayer!.transform.matrix.offset - trashCenter)
              .distance,
    );
    //want to scale down widget when in contact with trash
    if (distance! < 60) {
      controller.updateLayerTransform(
        controller.selectedLayer!.id,
        controller.selectedLayer!.transform.matrix,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = StoryEditorScope.of(context);
    _calculateDistance(controller);
    bool isOverTrash = (distance ?? 1) < 60;
    print(isOverTrash);
    print(distance);
    if (controller.hasSelection) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isOverTrash ? Colors.red.withAlpha(150) : Colors.transparent,
            border: BoxBorder.all(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Icon(
            Icons.delete_outline_rounded,
            size: 35,
            color: !isOverTrash ? Colors.red : Colors.white,
          ),
        ),
      );
    }
    return Container();
  }
}
