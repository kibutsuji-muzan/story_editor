import 'package:flutter/material.dart';
import 'package:story_editor/extensions/matrix_extension.dart';
import 'package:story_editor/src/core/utils/trash_can_metrics.dart';
import 'package:story_editor/src/editor/story_editor.dart';

class TrashCan extends StatefulWidget {
  const TrashCan({super.key});

  @override
  State<TrashCan> createState() => _TrashCanState();
}

class _TrashCanState extends State<TrashCan> {
  @override
  Widget build(BuildContext context) {
    final controller = StoryEditorScope.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        double distance = double.infinity;
        if (controller.hasSelection && controller.selectedLayer != null) {
          final viewportSize = TrashCanMetrics.viewportSizeFor(
            context,
            constraints: constraints,
          );
          final trashCenter = TrashCanMetrics.centerOffsetForViewport(
            viewportSize,
          );

          final naturalOffset =
              controller.selectedLayer!.transform.matrix.offset;
          distance = TrashCanMetrics.distanceToCenter(
            naturalOffset,
            trashCenter,
          );
        }

        final bool isOverTrash = distance < TrashCanMetrics.activationRadius;

        if (controller.hasSelection) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(TrashCanMetrics.margin),
              padding: const EdgeInsets.all(TrashCanMetrics.padding),
              decoration: BoxDecoration(
                color: isOverTrash
                    ? Colors.red.withAlpha(150)
                    : Colors.transparent,
                border: Border.all(
                  color: Colors.red,
                  width: TrashCanMetrics.borderWidth,
                ),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                size: TrashCanMetrics.iconSize,
                color: !isOverTrash ? Colors.red : Colors.white,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
