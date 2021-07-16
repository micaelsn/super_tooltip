import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:super_tooltip/src/models/tip_constraints.model.dart';
import 'package:super_tooltip/super_tooltip.dart';

import 'enums.dart';

class PopupBalloonLayoutDelegate extends SingleChildLayoutDelegate {
  PopupBalloonLayoutDelegate({
    required this.targetCenter,
    required this.direction,
    this.tipConstraints,
    this.outSidePadding = 0,
    this.position,
  });

  final Offset targetCenter;
  final TooltipDirection direction;
  final TipConstraints? tipConstraints;
  final TipPosition? position;
  final double outSidePadding;

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double? calcLeftMostXtoTarget() {
      double? leftMostXtoTarget;
      final left = position?.left;
      final right = position?.right;

      if (left != null) {
        leftMostXtoTarget = left;
      } else if (right != null) {
        leftMostXtoTarget = max(
            size.topLeft(Offset.zero).dx + outSidePadding,
            size.topRight(Offset.zero).dx -
                outSidePadding -
                childSize.width -
                right);
      } else {
        leftMostXtoTarget = max(
            outSidePadding,
            min(
                targetCenter.dx - childSize.width / 2,
                size.topRight(Offset.zero).dx -
                    outSidePadding -
                    childSize.width));
      }
      return leftMostXtoTarget;
    }

    double? calcTopMostYtoTarget() {
      double? topmostYtoTarget;
      if (position?.top != null) {
        topmostYtoTarget = position?.top;
      } else if (position?.bottom != null) {
        topmostYtoTarget = max(
            size.topLeft(Offset.zero).dy + outSidePadding,
            size.bottomRight(Offset.zero).dy -
                outSidePadding -
                childSize.height -
                position!.bottom!);
      } else {
        topmostYtoTarget = max(
            outSidePadding,
            min(
                targetCenter.dy - childSize.height / 2,
                size.bottomRight(Offset.zero).dy -
                    outSidePadding -
                    childSize.height));
      }
      return topmostYtoTarget;
    }

    switch (direction) {
      //
      case TooltipDirection.down:
        return Offset(calcLeftMostXtoTarget()!, targetCenter.dy);

      case TooltipDirection.up:
        final top = position?.top ?? targetCenter.dy - childSize.height;
        return Offset(calcLeftMostXtoTarget()!, top);

      case TooltipDirection.left:
        final left = position?.left ?? targetCenter.dx - childSize.width;
        return Offset(left, calcTopMostYtoTarget()!);

      case TooltipDirection.right:
        return Offset(
          targetCenter.dx,
          calcTopMostYtoTarget()!,
        );

      default:
        throw AssertionError(direction);
    }
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // print("ParentConstraints: $constraints");

    var calcMinWidth = tipConstraints?.minWidth ?? 0.0;
    var calcMaxWidth = tipConstraints?.maxWidth ?? double.infinity;
    var calcMinHeight = tipConstraints?.minHeight ?? 0.0;
    var calcMaxHeight = tipConstraints?.maxHeight ?? double.infinity;

    void calcMinMaxWidth() {
      final left = position?.left;
      final right = position?.right;

      if (left != null && right != null) {
        calcMaxWidth = constraints.maxWidth - (left + right);
      } else if ((left != null && right == null) ||
          (left == null && right != null)) {
        // make sure that the sum of left, right + maxwidth isn't bigger than the screen width.
        final sideDelta = (left ?? 0.0) + (right ?? 0.0) + outSidePadding;
        if (calcMaxWidth > constraints.maxWidth - sideDelta) {
          calcMaxWidth = constraints.maxWidth - sideDelta;
        }
      } else {
        if (calcMaxWidth > constraints.maxWidth - 2 * outSidePadding) {
          calcMaxWidth = constraints.maxWidth - 2 * outSidePadding;
        }
      }
    }

    void calcMinMaxHeight() {
      final top = position?.top;
      final bottom = position?.bottom;
      if (top != null && bottom != null) {
        calcMaxHeight = constraints.maxHeight - (top + bottom);
      } else if ((top != null && bottom == null) ||
          (top == null && bottom != null)) {
        // make sure that the sum of top, bottom + maxHeight isn't bigger than the screen Height.
        final sideDelta =
            (position?.top ?? 0.0) + (position?.bottom ?? 0.0) + outSidePadding;
        if (calcMaxHeight > constraints.maxHeight - sideDelta) {
          calcMaxHeight = constraints.maxHeight - sideDelta;
        }
      } else {
        if (calcMaxHeight > constraints.maxHeight - 2 * outSidePadding) {
          calcMaxHeight = constraints.maxHeight - 2 * outSidePadding;
        }
      }
    }

    switch (direction) {
      //
      case TooltipDirection.down:
        calcMinMaxWidth();
        final bottom = position?.bottom;

        if (bottom != null) {
          calcMinHeight =
              calcMaxHeight = constraints.maxHeight - bottom - targetCenter.dy;
        } else {
          calcMaxHeight = min(
                  (tipConstraints?.maxHeight ?? constraints.maxHeight),
                  constraints.maxHeight - targetCenter.dy) -
              outSidePadding;
        }
        break;

      case TooltipDirection.up:
        calcMinMaxWidth();
        final top = position?.top;

        if (top != null) {
          calcMinHeight = calcMaxHeight = targetCenter.dy - top;
        } else {
          calcMaxHeight = min(
                  (tipConstraints?.maxHeight ?? constraints.maxHeight),
                  targetCenter.dy) -
              outSidePadding;
        }
        break;

      case TooltipDirection.right:
        calcMinMaxHeight();
        final right = position?.right;
        if (right != null) {
          calcMinWidth =
              calcMaxWidth = constraints.maxWidth - right - targetCenter.dx;
        } else {
          calcMaxWidth = min((tipConstraints?.maxWidth ?? constraints.maxWidth),
                  constraints.maxWidth - targetCenter.dx) -
              outSidePadding;
        }
        break;

      case TooltipDirection.left:
        calcMinMaxHeight();
        final left = position?.left;
        if (left != null) {
          calcMinWidth = calcMaxWidth = targetCenter.dx - left;
        } else {
          calcMaxWidth = min((tipConstraints?.maxWidth ?? constraints.maxWidth),
                  targetCenter.dx) -
              outSidePadding;
        }
        break;

      default:
        throw AssertionError(direction);
    }

    final childConstraints = BoxConstraints(
        minWidth: calcMinWidth > calcMaxWidth ? calcMaxWidth : calcMinWidth,
        maxWidth: calcMaxWidth,
        minHeight:
            calcMinHeight > calcMaxHeight ? calcMaxHeight : calcMinHeight,
        maxHeight: calcMaxHeight);

    // print("Child constraints: $childConstraints");

    return childConstraints;
  }

  @override
  bool shouldRelayout(SingleChildLayoutDelegate oldDelegate) {
    return false;
  }
}
