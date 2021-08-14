import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:super_tooltip/src/models/super_tooltip.model.dart';
import 'package:super_tooltip/src/public_enums.dart';
import 'package:super_tooltip/src/extensions.dart';

import 'public_enums.dart';

class CloseObject extends StatelessWidget {
  const CloseObject(
    this.tooltip, {
    Key? key,
    required this.direction,
    required this.close,
  }) : super(key: key);

  final SuperTooltip tooltip;
  final TipDirection direction;
  final OnCloseCallback close;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final closePosition = tooltip.closeTipObject.position;

        if (closePosition == null) return const SizedBox(height: 0);

        double? right, top;
        var _wrapInSafeArea = false;

        switch (direction) {
          //
          // LEFT: -------------------------------------
          case TipDirection.left:
            _wrapInSafeArea = true;
            right = tooltip.arrowDecoration.distanceAway + 3.0;
            top = 12;
            if (closePosition.isOutside) {
              right -= direction.getMargin(tooltip).right;
            } else
              throw AssertionError(closePosition);
            break;

          // RIGHT/UP: ---------------------------------
          case TipDirection.right:
            _wrapInSafeArea = true;
            right = 5.0;
            if (closePosition.isInside) {
              top = 2.0;
            } else if (closePosition.isOutside) {
              top = 0.0;
            } else
              throw AssertionError(closePosition);
            break;
          case TipDirection.up:
            right = 5.0;
            if (closePosition.isInside) {
              top = 2.0;
            } else if (closePosition.isOutside) {
              top = 0.0;
            } else
              throw AssertionError(closePosition);
            break;

          // DOWN: -------------------------------------
          case TipDirection.down:
            // If this value gets negative the Shadow gets clipped. The problem occurs is arrowlength + arrowTipDistance
            // is smaller than _outSideCloseButtonPadding which would mean arrowLength would need to be increased if the button is ouside.
            right = 2.0;
            if (closePosition.isInside) {
              top = tooltip.arrowDecoration.distanceAway + 2.0;
            } else if (closePosition.isOutside) {
              top = -tooltip.closeTipObject.height +
                  tooltip.arrowDecoration.distanceAway -
                  2;
            } else
              throw AssertionError(closePosition);
            break;
        }

        final closeObject = SizedBox(
          height: tooltip.closeTipObject.height,
          width: tooltip.closeTipObject.width,
          child: tooltip.closeTipObject.child ?? const Icon(Icons.close),
        );

        return Positioned(
          right: right,
          top: top,
          child: GestureDetector(
            onTap: close,
            child: AbsorbPointer(
              absorbing: true,
              child:
                  _wrapInSafeArea ? SafeArea(child: closeObject) : closeObject,
            ),
          ),
        );
      },
    );
  }
}
