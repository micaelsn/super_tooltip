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

        if (closePosition.isNone) {
          return const Positioned(child: SizedBox(height: 0));
        }

        double? x, y;
        var _wrapInSafeArea = true;
        final hasSnaps = tooltip.tipContent.position.hasSnaps;
        final minDistance = tooltip.arrowDecoration.distanceAway;

        switch (direction) {
          case TipDirection.left:
            if (hasSnaps) {
              y = closeObject.margin.top;
            } else {
              _wrapInSafeArea = false;
              y = closeObject.margin.top;
            }

            closePositionHandler(
              closePosition,
              inside: () {
                x = minDistance + closeObject.margin.left;
              },
              outside: () {
                x = minDistance -
                    closeObject.width -
                    1 -
                    closeObject.margin.left;
              },
            );

            break;

          case TipDirection.right:
            x = closeObject.margin.right;

            if (hasSnaps) {
              y = closeObject.margin.top;
            } else if (closePosition.isOutside) {
              y = -(closeObject.height * 2) -
                  -extraPadding -
                  closeObject.margin.top;
            } else {
              y = -closeObject.height + extraPadding + closeObject.margin.top;
            }
            break;
          case TipDirection.up:
            x = closeObject.margin.right;
            if (hasSnaps) {
              y = closeObject.margin.top;
            }
            closePositionHandler(
              closePosition,
              inside: () {
                y = -minDistance + closeObject.margin.top;
              },
              outside: () {
                y = (-closeObject.height + (extraPadding * 2)) -
                    closeObject.margin.top;
              },
            );
            // y = 0;

            break;

          // DOWN: -------------------------------------
          case TipDirection.down:
            // If this value gets negative the Shadow gets clipped. The problem occurs is arrowlength + arrowTipDistance
            // is smaller than _outSideCloseButtonPadding which would mean arrowLength would need to be increased if the button is ouside.
            x = closeObject.margin.right;
            _wrapInSafeArea = false;
            if (closePosition.isInside) {
              y = tooltip.arrowDecoration.distanceAway + closeObject.margin.top;
            } else {
              y = -tooltip.closeTipObject.height +
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
          right: x,
          top: y,
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
