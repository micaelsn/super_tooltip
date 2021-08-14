import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:super_tooltip/src/models/absolute_position.dart';
import 'package:super_tooltip/src/models/tip_constraints.model.dart';
import 'package:super_tooltip/super_tooltip.dart';

import 'public_enums.dart';

class PopupBalloonLayoutDelegate extends SingleChildLayoutDelegate {
  PopupBalloonLayoutDelegate({
    required this.targetCenter,
    this.tipConstraints,
    this.margin = const EdgeInsets.all(0),
    required this.position,
  });

  final Offset targetCenter;
  final TipConstraints? tipConstraints;
  final AbsolutePosition position;
  final EdgeInsets margin;

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double? calcLeftMostXtoTarget() {
      double? leftMostXtoTarget;
      final left = position.left;
      final right = position.right;

      if (left != null) {
        leftMostXtoTarget = left;
      } else if (right != null) {
        leftMostXtoTarget = max(
            size.topLeft(Offset.zero).dx + margin.left,
            size.topRight(Offset.zero).dx -
                margin.right -
                childSize.width -
                right);
      } else {
        leftMostXtoTarget = max(
            margin.left,
            min(
                targetCenter.dx - childSize.width / 2,
                size.topRight(Offset.zero).dx -
                    margin.right -
                    childSize.width));
      }
      return leftMostXtoTarget;
    }

    double? calcTopMostYtoTarget() {
      double? topmostYtoTarget;
      final top = position.top;
      final bottom = position.bottom;
      if (top != null) {
        topmostYtoTarget = top;
      } else if (bottom != null) {
        topmostYtoTarget = max(
            size.topLeft(Offset.zero).dy + margin.top,
            size.bottomRight(Offset.zero).dy -
                margin.bottom -
                childSize.height -
                bottom);
      } else {
        topmostYtoTarget = max(
            margin.top,
            min(
                targetCenter.dy - childSize.height / 2,
                size.bottomRight(Offset.zero).dy -
                    margin.bottom -
                    childSize.height));
      }
      return topmostYtoTarget;
    }

    switch (position.direction) {
      //
      case TipDirection.down:
        return Offset(calcLeftMostXtoTarget()!, targetCenter.dy);

      case TipDirection.up:
        final top = position.top ?? targetCenter.dy - childSize.height;
        return Offset(calcLeftMostXtoTarget()!, top);

      case TipDirection.left:
        final left = position.left ?? targetCenter.dx - childSize.width;
        return Offset(left, calcTopMostYtoTarget()!);

      case TipDirection.right:
        return Offset(
          targetCenter.dx,
          calcTopMostYtoTarget()!,
        );
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
      final left = position.left;
      final right = position.right;

      if (left != null && right != null) {
        calcMaxWidth = constraints.maxWidth - (left + right);
      } else if ((left != null && right == null) ||
          (left == null && right != null)) {
        // make sure that the sum of left, right + maxwidth isn't bigger than the screen width.
        final sideDelta =
            (left ?? 0.0) + (right ?? 0.0) + margin.left + margin.right;
        if (calcMaxWidth > constraints.maxWidth - sideDelta) {
          calcMaxWidth = constraints.maxWidth - sideDelta;
        }
      } else {
        if (calcMaxWidth >
            constraints.maxWidth - 2 * (margin.left + margin.right)) {
          calcMaxWidth =
              constraints.maxWidth - 2 * (margin.left + margin.right);
        }
      }
    }

    void calcMinMaxHeight() {
      final top = position.top;
      final bottom = position.bottom;
      if (top != null && bottom != null) {
        calcMaxHeight = constraints.maxHeight - (top + bottom);
      } else if ((top != null && bottom == null) ||
          (top == null && bottom != null)) {
        // make sure that the sum of top, bottom + maxHeight isn't bigger than the screen Height.
        final sideDelta = (position.top ?? 0.0) +
            (position.bottom ?? 0.0) +
            (margin.top + margin.bottom);
        if (calcMaxHeight > constraints.maxHeight - sideDelta) {
          calcMaxHeight = constraints.maxHeight - sideDelta;
        }
      } else {
        if (calcMaxHeight >
            constraints.maxHeight - 2 * (margin.top + margin.bottom)) {
          calcMaxHeight =
              constraints.maxHeight - 2 * (margin.top + margin.bottom);
        }
      }
    }

    switch (position.direction) {
      //
      case TipDirection.down:
        calcMinMaxWidth();
        final bottom = position.bottom;

        if (bottom != null) {
          calcMinHeight =
              calcMaxHeight = constraints.maxHeight - bottom - targetCenter.dy;
        } else {
          calcMaxHeight = min(
                  (tipConstraints?.maxHeight ?? constraints.maxHeight),
                  constraints.maxHeight - targetCenter.dy) -
              (margin.top + margin.bottom);
        }
        break;

      case TipDirection.up:
        calcMinMaxWidth();
        final top = position.top;

        if (top != null) {
          calcMinHeight = calcMaxHeight = targetCenter.dy - top;
        } else {
          calcMaxHeight = min(
                  (tipConstraints?.maxHeight ?? constraints.maxHeight),
                  targetCenter.dy) -
              (margin.top + margin.bottom);
        }
        break;

      case TipDirection.right:
        calcMinMaxHeight();
        final right = position.right;
        if (right != null) {
          calcMinWidth =
              calcMaxWidth = constraints.maxWidth - right - targetCenter.dx;
        } else {
          calcMaxWidth = min((tipConstraints?.maxWidth ?? constraints.maxWidth),
                  constraints.maxWidth - targetCenter.dx) -
              (margin.left + margin.right);
        }
        break;

      case TipDirection.left:
        calcMinMaxHeight();
        final left = position.left;
        if (left != null) {
          calcMinWidth = calcMaxWidth = targetCenter.dx - left;
        } else {
          calcMaxWidth = min((tipConstraints?.maxWidth ?? constraints.maxWidth),
                  targetCenter.dx) -
              (margin.left + margin.right);
        }
        break;
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
