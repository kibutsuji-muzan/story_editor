import 'package:flutter/material.dart';
import 'package:story_editor/extensions/matrix_extension.dart';
import 'package:story_editor/src/core/utils/layer_frame_metrics.dart';
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
          final viewportSize = LayerFrameMetrics.viewportSizeFor(
            context,
            constraints: constraints,
          );
          final trashCenter = LayerFrameMetrics.centerOffsetForViewport(
            context,
            viewportSize,
          );

          final naturalOffset =
              controller.selectedLayer!.transform.matrix.offset;
          distance = LayerFrameMetrics.distanceToCenter(
            naturalOffset,
            trashCenter,
          );
        }

        final bool isOverTrash =
            distance < LayerFrameMetrics.trashActivationRadius;

        if (controller.hasSelection) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: Duration(microseconds: 500),
              curve: Curves.easeOutCubic,
              margin: EdgeInsets.all(LayerFrameMetrics.trashMargin(context)),
              padding: EdgeInsets.all(LayerFrameMetrics.trashPadding(context)),
              decoration: BoxDecoration(
                color: isOverTrash
                    ? Colors.red.withAlpha(150)
                    : Colors.transparent,
                border: Border.all(
                  color: Colors.red,
                  width: LayerFrameMetrics.trashBorderWidth(context),
                ),
                borderRadius: BorderRadius.circular(
                  LayerFrameMetrics.trashBorderRadius(context),
                ),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                size: LayerFrameMetrics.trashIconSize(context),
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
