import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:super_tooltip/src/models/models.dart';
import 'package:super_tooltip/src/private_enums.dart';

import 'models/super_tooltip.model.dart';
import 'shape_overlay.dart';

class SuperTooltipBackground extends StatelessWidget {
  const SuperTooltipBackground({
    Key? key,
    required this.targetCenter,
    required this.background,
    required this.close,
  }) : super(key: key);

  final Offset targetCenter;
  final TipBackground background;
  final OnCloseCallback close;

  @override
  Widget build(BuildContext context) {
    late Widget backgroundContent;

    final touchThrough = background.touchThrough;
    final position = touchThrough?.position != null
        ? touchThrough!.position!(targetCenter)
        : targetCenter;

    final shapeOverlay = ShapeOverlay(
      touchThrough?.isCustom ?? false
          ? touchThrough!.area
          : Rect.fromCenter(
              center: Offset(
                position.dx,
                position.dy,
              ),
              width: (touchThrough?.area.width ?? 0),
              height: (touchThrough?.area.height ?? 0),
            ),
      touchThrough?.shape ?? ClipAreaShape.rectangle,
      touchThrough?.borderRadius ?? 0,
      background.outsideColor,
    );
    final backgroundDecoration =
        DecoratedBox(decoration: ShapeDecoration(shape: shapeOverlay));

    if (background.dismissible && background.absorbPointerEvents) {
      backgroundContent = GestureDetector(
        onTap: close,
        child: backgroundDecoration,
      );
    } else if (background.dismissible && !background.absorbPointerEvents) {
      backgroundContent = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          if (!(shapeOverlay.getExclusion()?.contains(event.localPosition) ??
              false)) {
            close();
          }
        },
        child: IgnorePointer(child: backgroundDecoration),
      );
    } else if (!background.dismissible && background.absorbPointerEvents) {
      backgroundContent = backgroundDecoration;
    } else if (!background.dismissible && !background.absorbPointerEvents) {
      backgroundContent = IgnorePointer(child: backgroundDecoration);
    } else {
      backgroundContent = backgroundDecoration;
    }
    return backgroundContent;
  }
}
