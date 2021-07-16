import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';
import 'models/border_decoration.model.dart';
import 'models/pointer_decoration.model.dart';
import 'models/tip_position.model.dart';

class BubbleShape extends ShapeBorder {
  BubbleShape({
    required this.direction,
    required this.targetCenter,
    PointerDecoration? pointerDecoration,
    BorderDecoration? borderDecoration,
    required this.position,
  })  : _borderDecoration = borderDecoration ?? const BorderDecoration(),
        _pointerDecoration = pointerDecoration ?? const PointerDecoration();

  final TipDirection direction;
  final Offset targetCenter;
  final PointerDecoration _pointerDecoration;
  final BorderDecoration _borderDecoration;
  final TipPosition position;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10.0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    late double topLeftRadius,
        topRightRadius,
        bottomLeftRadius,
        bottomRightRadius;

    /// starts at the bottom-left corner, and ends at the top-right corner
    /// Bottom Left => Top Left => Top Right
    ///
    /// Bottom left corner & Top right corner are added
    Path _getRightTopPath(Rect rect) {
      return Path()
        // start at bottom left corner
        ..moveTo(rect.left, rect.bottom - bottomLeftRadius)
        // draw to top left corner
        ..lineTo(rect.left, rect.top + topLeftRadius)
        // add top left corner
        ..arcToPoint(Offset(rect.left + topLeftRadius, rect.top),
            radius: Radius.circular(topLeftRadius))
        // draw to top right corner
        ..lineTo(rect.right - topRightRadius, rect.top)
        // add top right corner
        ..arcToPoint(Offset(rect.right, rect.top + topRightRadius),
            radius: Radius.circular(topRightRadius), clockwise: true);
    }

    /// starts at the bottom-left corner, and ends at the top-right corner
    /// Bottom Left => Bottom Right => Top Right
    ///
    /// Bottom right corner & Top right corner are added
    Path _getBottomRightPath(Rect rect) {
      return Path()
        // start at bottom left corner
        ..moveTo(rect.left + bottomLeftRadius, rect.bottom)
        // draw to bottom right corner
        ..lineTo(rect.right - bottomRightRadius, rect.bottom)
        // add bottom right corner
        ..arcToPoint(Offset(rect.right, rect.bottom - bottomRightRadius),
            radius: Radius.circular(bottomRightRadius), clockwise: false)
        // draw to top right corner
        ..lineTo(rect.right, rect.top + topRightRadius)
        // add top right corner
        ..arcToPoint(Offset(rect.right - topRightRadius, rect.top),
            radius: Radius.circular(topRightRadius), clockwise: false);
    }

    topLeftRadius = position.hasTopLeftRadius ? 0.0 : _borderDecoration.radius;
    topRightRadius =
        position.hasTopRightRadius ? 0.0 : _borderDecoration.radius;
    bottomLeftRadius =
        position.hasBottomLeftRadius ? 0.0 : _borderDecoration.radius;
    bottomRightRadius =
        position.hasBottomRightRadius ? 0.0 : _borderDecoration.radius;

    switch (direction) {
      // draws arrow pointing up
      case TipDirection.down:
        return _getBottomRightPath(rect)
          // draw to the right of the arrow
          ..lineTo(
              min(
                  max(
                      targetCenter.dx + _pointerDecoration.baseWidth / 2,
                      rect.left +
                          _borderDecoration.radius +
                          _pointerDecoration.baseWidth),
                  rect.right - topRightRadius),
              rect.top)
          // draw to arrow tip
          ..lineTo(targetCenter.dx,
              targetCenter.dy + _pointerDecoration.distanceFromCenter)
          // draw to the left of the arrow
          ..lineTo(
              max(
                  min(
                      targetCenter.dx - _pointerDecoration.baseWidth / 2,
                      rect.right -
                          topLeftRadius -
                          _pointerDecoration.baseWidth),
                  rect.left + topLeftRadius),
              rect.top)
          // to top left side
          ..lineTo(rect.left + topLeftRadius, rect.top)
          // add top left corner
          ..arcToPoint(Offset(rect.left, rect.top + topLeftRadius),
              radius: Radius.circular(topLeftRadius), clockwise: false)
          // to bottom left side
          ..lineTo(rect.left, rect.bottom - bottomLeftRadius)
          // add bottom left corner
          ..arcToPoint(Offset(rect.left + bottomLeftRadius, rect.bottom),
              radius: Radius.circular(bottomLeftRadius), clockwise: false);

      // draws arrow pointing down
      case TipDirection.up:
        return _getRightTopPath(rect)
          // draw to the bottom right
          ..lineTo(rect.right, rect.bottom - bottomRightRadius)
          // add bottom right corner
          ..arcToPoint(Offset(rect.right - bottomRightRadius, rect.bottom),
              radius: Radius.circular(bottomRightRadius), clockwise: true)
          // draw to the right of the arrow
          ..lineTo(
              min(
                  max(
                      targetCenter.dx + _pointerDecoration.baseWidth / 2,
                      rect.left +
                          bottomLeftRadius +
                          _pointerDecoration.baseWidth),
                  rect.right - bottomRightRadius),
              rect.bottom)
          // draw to arrow tip
          ..lineTo(targetCenter.dx, targetCenter.dy - _pointerDecoration.height)
          // draw to the left of the arrow
          ..lineTo(
              max(
                  min(
                      targetCenter.dx - _pointerDecoration.baseWidth / 2,
                      rect.right -
                          bottomRightRadius -
                          _pointerDecoration.baseWidth),
                  rect.left + bottomLeftRadius),
              rect.bottom)
          // draw to bottom left
          ..lineTo(rect.left + bottomLeftRadius, rect.bottom)
          // add bottom left corner
          ..arcToPoint(Offset(rect.left, rect.bottom - bottomLeftRadius),
              radius: Radius.circular(bottomLeftRadius), clockwise: true)
          // draw to top right
          ..lineTo(rect.left, rect.top + topLeftRadius)
          // add top right corner
          ..arcToPoint(Offset(rect.left + topLeftRadius, rect.top),
              radius: Radius.circular(topLeftRadius), clockwise: true);

      // draws arrow pointing to the right
      case TipDirection.left:
        return _getRightTopPath(rect)
          // draw down to the start of the arrow
          ..lineTo(
              rect.right,
              max(
                  min(
                      targetCenter.dy - _pointerDecoration.baseWidth / 2,
                      rect.bottom -
                          bottomRightRadius -
                          _pointerDecoration.baseWidth),
                  rect.top + topRightRadius))
          // draw to arrow tip
          ..lineTo(targetCenter.dx - _pointerDecoration.height, targetCenter.dy)
          // draw to the end of the arrow
          ..lineTo(
              rect.right,
              min(targetCenter.dy + _pointerDecoration.baseWidth / 2,
                  rect.bottom - bottomRightRadius))
          // draw to bottom right
          ..lineTo(rect.right, rect.bottom - _borderDecoration.radius)
          // add bottom right corner
          ..arcToPoint(Offset(rect.right - bottomRightRadius, rect.bottom),
              radius: Radius.circular(bottomRightRadius), clockwise: true)
          // draw to bottom left
          ..lineTo(rect.left + bottomLeftRadius, rect.bottom)
          // add bottom left corner
          ..arcToPoint(Offset(rect.left, rect.bottom - bottomLeftRadius),
              radius: Radius.circular(bottomLeftRadius), clockwise: true);

      // draws arrow pointing to the left
      case TipDirection.right:
        return _getBottomRightPath(rect)
          // draw to top left
          ..lineTo(rect.left + topLeftRadius, rect.top)
          // add top left corner
          ..arcToPoint(Offset(rect.left, rect.top + topLeftRadius),
              radius: Radius.circular(topLeftRadius), clockwise: false)
          // draw to the start of the arrow
          ..lineTo(
              rect.left,
              max(
                  min(
                      targetCenter.dy - _pointerDecoration.baseWidth / 2,
                      rect.bottom -
                          bottomLeftRadius -
                          _pointerDecoration.baseWidth),
                  rect.top + topLeftRadius))

          // draw to start of arrow
          ..lineTo(
              targetCenter.dx + _pointerDecoration.baseWidth, targetCenter.dy)

          //  draw to end of arrow
          ..lineTo(
              rect.left,
              min(targetCenter.dy + _pointerDecoration.baseWidth / 2,
                  rect.bottom - bottomLeftRadius))
          // draw to bottom left
          ..lineTo(rect.left, rect.bottom - bottomLeftRadius)
          // add bottom left corner
          ..arcToPoint(Offset(rect.left + bottomLeftRadius, rect.bottom),
              radius: Radius.circular(bottomLeftRadius), clockwise: false);

      default:
        throw AssertionError(direction);
    }
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    // adds a border
    var paint = Paint()
      ..color = _borderDecoration.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _borderDecoration.width;

    canvas.drawPath(getOuterPath(rect), paint);
    paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = _borderDecoration.width;

    // if the position snaps, we draw the tooltip here
    // if it doesn't snap, nothing is drawn here
    if (position.isRightSide) {
      if (position.snapsVertical) {
        canvas.drawPath(
            Path()
              ..moveTo(rect.right, rect.top)
              ..lineTo(rect.right, rect.bottom),
            paint);
      } else {
        canvas.drawPath(
            Path()
              ..moveTo(rect.right, rect.top + _borderDecoration.width / 2)
              ..lineTo(rect.right, rect.bottom - _borderDecoration.width / 2),
            paint);
      }
    }
    if (position.isLeftSide) {
      if (position.snapsVertical) {
        canvas.drawPath(
            Path()
              ..moveTo(rect.left, rect.top)
              ..lineTo(rect.left, rect.bottom),
            paint);
      } else {
        canvas.drawPath(
            Path()
              ..moveTo(rect.left, rect.top + _borderDecoration.width / 2)
              ..lineTo(rect.left, rect.bottom - _borderDecoration.width / 2),
            paint);
      }
    }
    if (position.isTopSide) {
      if (position.snapsHorizontal) {
        canvas.drawPath(
            Path()
              ..moveTo(rect.right, rect.top)
              ..lineTo(rect.left, rect.top),
            paint);
      } else {
        canvas.drawPath(
            Path()
              ..moveTo(rect.right - _borderDecoration.width / 2, rect.top)
              ..lineTo(rect.left + _borderDecoration.width / 2, rect.top),
            paint);
      }
    }
    if (position.isBottomSide) {
      if (position.snapsHorizontal) {
        canvas.drawPath(
            Path()
              ..moveTo(rect.right, rect.bottom)
              ..lineTo(rect.left, rect.bottom),
            paint);
      } else {
        canvas.drawPath(
            Path()
              ..moveTo(rect.right - _borderDecoration.width / 2, rect.bottom)
              ..lineTo(rect.left + _borderDecoration.width / 2, rect.bottom),
            paint);
      }
    }
  }

  @override
  ShapeBorder scale(double t) {
    return BubbleShape(
      direction: direction,
      targetCenter: targetCenter,
      borderDecoration: _borderDecoration,
      position: position,
      pointerDecoration: _pointerDecoration,
    );
  }
}
