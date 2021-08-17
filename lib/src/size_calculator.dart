import 'package:flutter/material.dart';
import 'package:super_tooltip/src/extensions.dart';
import 'package:super_tooltip/super_tooltip.dart';

class TipSize {
  TipSize(this.tooltip, this.direction, this.targetCenter) {
    final closeObject = tooltip.closeTipObject;
    final closePosition = closeObject.position;

    double? x, y;
    var _wrapInSafeArea = true;
    final hasSnaps = tooltip.tipContent.position.hasSnaps;
    final posMinDistance = tooltip.arrowDecoration.distanceAway + 1;
    final negMinDistance = tooltip.arrowDecoration.distanceAway - 1;

    switch (direction) {
      case TipDirection.left:
        if (hasSnaps) {
          y = closeObject.margin.top;
        } else {
          _wrapInSafeArea = false;
        }

        closePositionHandler(
          closePosition,
          inside: () {
            if (!hasSnaps) {
              y = closeObject.margin.top + 1;
            }
            x = posMinDistance + closeObject.margin.left;
          },
          outside: () {
            if (hasSnaps) {
              x = negMinDistance - closeObject.width - closeObject.margin.left;
            } else {
              y = -closeObject.margin.bottom - closeObject.height - 1;
              x = posMinDistance + closeObject.margin.left;
            }
          },
        );

        break;

      case TipDirection.right:
        x = closeObject.margin.right;
        if (hasSnaps) {
          y = closeObject.margin.top;
        } else {
          _wrapInSafeArea = false;

          closePositionHandler(
            closePosition,
            inside: () {
              y = closeObject.margin.top;
            },
            outside: () {
              y = -closeObject.margin.bottom - closeObject.height;
            },
          );
        }

        break;
      case TipDirection.up:
        x = closeObject.margin.right + 1;

        if (hasSnaps) {
          y = closeObject.margin.top;
        } else {
          _wrapInSafeArea = false;
          closePositionHandler(
            closePosition,
            inside: () {
              y = closeObject.margin.top;
            },
            outside: () {
              y = -closeObject.margin.bottom - closeObject.height - 1;
            },
          );
        }

        break;

      // DOWN: -------------------------------------
      case TipDirection.down:
        // If this value gets negative the Shadow gets clipped. The problem occurs is arrowlength + arrowTipDistance
        // is smaller than _outSideCloseButtonPadding which would mean arrowLength would need to be increased if the button is ouside.
        x = closeObject.margin.right + 1;
        _wrapInSafeArea = false;
        closePositionHandler(
          closePosition,
          inside: () {
            y = tooltip.arrowDecoration.distanceAway + closeObject.margin.top;
          },
          outside: () {
            y = -tooltip.closeTipObject.height +
                tooltip.arrowDecoration.distanceAway -
                closeObject.margin.bottom -
                1;
          },
        );
        break;
    }
    _x = x;
    _y = y;
    wrapInSafeArea = _wrapInSafeArea;
  }

  final SuperTooltip tooltip;
  final TipDirection direction;
  final Offset targetCenter;

  late final bool wrapInSafeArea;
  late final double? _x;
  late final double? _y;
  double? get x => _x;
  double? get y => _y;
}
