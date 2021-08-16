import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:super_tooltip/src/models/super_tooltip.model.dart';
import 'package:super_tooltip/src/models/enums/public_enums.dart';
import 'package:super_tooltip/src/extensions.dart';

import 'models/enums/public_enums.dart';

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
    const extraPadding = 6.0;
    return Builder(
      builder: (context) {
        final closeObject = tooltip.closeTipObject;
        final closePosition = closeObject.position;

        if (closePosition == null) return const SizedBox(height: 0);

        double? right, top;
        var _wrapInSafeArea = true;
        final hasSnaps = tooltip.tipContent.position.hasSnaps;

        switch (direction) {
          case TipDirection.left:
            if (hasSnaps) {
              top = closeObject.margin.top;
            } else
              top = -closeObject.height + extraPadding + closeObject.margin.top;
            final minDistance = tooltip.arrowDecoration.distanceAway;
            right = minDistance +
                (minDistance - closeObject.width) +
                (extraPadding - 2) +
                closeObject.margin.right;
            if (closePosition.isOutside) right += -closeObject.width + 1;
            break;

          case TipDirection.right:
            right = closeObject.margin.right;

            if (hasSnaps) {
              top = closeObject.margin.top;
            } else if (closePosition.isOutside) {
              top = -(closeObject.height * 2) -
                  -extraPadding -
                  closeObject.margin.top;
            } else {
              top = -closeObject.height + extraPadding + closeObject.margin.top;
            }
            break;
          case TipDirection.up:
            right = closeObject.margin.right;

            if (hasSnaps) {
              top = closeObject.margin.top;
            } else if (closePosition.isOutside) {
              top = (-closeObject.height + (extraPadding * 2)) -
                  closeObject.margin.top;
            } else {
              top = -closeObject.height + extraPadding + closeObject.margin.top;
            }
            break;

          // DOWN: -------------------------------------
          case TipDirection.down:
            // If this value gets negative the Shadow gets clipped. The problem occurs is arrowlength + arrowTipDistance
            // is smaller than _outSideCloseButtonPadding which would mean arrowLength would need to be increased if the button is ouside.
            right = closeObject.margin.right;
            _wrapInSafeArea = false;
            if (closePosition.isInside) {
              top =
                  tooltip.arrowDecoration.distanceAway + closeObject.margin.top;
            } else {
              top = -tooltip.closeTipObject.height +
                  tooltip.arrowDecoration.distanceAway -
                  closeObject.margin.bottom -
                  1;
            }
            break;
        }

        final closeWidget = SizedBox(
          height: tooltip.closeTipObject.height,
          width: tooltip.closeTipObject.width,
          child: tooltip.closeTipObject.child ??
              const Center(
                child: Icon(Icons.close),
              ),
        );

        return Positioned(
          right: right,
          top: top,
          child: GestureDetector(
            onTap: close,
            child: AbsorbPointer(
              absorbing: true,
              child:
                  _wrapInSafeArea ? SafeArea(child: closeWidget) : closeWidget,
            ),
          ),
        );
      },
    );
  }
}
