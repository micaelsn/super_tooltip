import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:super_tooltip/src/extensions.dart';
import 'package:super_tooltip/src/models/enums/public_enums.dart';
import 'package:super_tooltip/src/models/super_tooltip.model.dart';
import 'package:super_tooltip/src/size_calculator.dart';

import 'models/enums/public_enums.dart';

class CloseObject extends StatelessWidget {
  const CloseObject(
    this.tooltip, {
    Key? key,
    required this.direction,
    required this.close,
    required this.targetCenter,
  }) : super(key: key);

  final SuperTooltip tooltip;
  final TipDirection direction;
  final Offset targetCenter;
  final OnCloseCallback close;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (tooltip.closeTipObject.position.isNone) {
          return const Positioned(child: SizedBox(height: 0));
        }
        final position = TipSize(tooltip, direction, targetCenter);
        final child = tooltip.closeTipObject.builder;

        final closeWidget = SizedBox(
          height: tooltip.closeTipObject.height,
          width: tooltip.closeTipObject.width,
          child: child == null
              ? GestureDetector(
                  onTap: close,
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: const Icon(Icons.close),
                  ),
                )
              : child(context, close),
        );

        return Positioned(
          right: position.x,
          top: position.y,
          child: Material(
            type: MaterialType.transparency,
            child: position.wrapInSafeArea
                ? SafeArea(child: closeWidget)
                : closeWidget,
          ),
        );
      },
    );
  }
}
