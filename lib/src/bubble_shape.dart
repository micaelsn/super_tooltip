import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:super_tooltip/src/models/absolute_position.dart';

import 'models/arrow_decoration.model.dart';
import 'models/border_decoration.model.dart';
import 'models/enums/public_enums.dart';

class BubbleShape extends ShapeBorder {
  BubbleShape({
    required this.targetCenter,
    ArrowDecoration? arrowDecoration,
    BorderDecoration? borderDecoration,
    required this.position,
    required this.backgroundColor,
  })  : _borderDecoration = borderDecoration ?? const BorderDecoration(),
        _arrowDecoration = arrowDecoration ?? const ArrowDecoration();

  final Offset targetCenter;
  final ArrowDecoration _arrowDecoration;
  final BorderDecoration _borderDecoration;
  final AbsolutePosition position;
  final Color backgroundColor;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

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

    topLeftRadius = position.hasTopLeftRadius ? _borderDecoration.radius : 0.0;
    topRightRadius =
        position.hasTopRightRadius ? _borderDecoration.radius : 0.0;
    bottomLeftRadius =
        position.hasBottomLeftRadius ? _borderDecoration.radius : 0.0;
    bottomRightRadius =
        position.hasBottomRightRadius ? _borderDecoration.radius : 0.0;

    switch (position.direction) {
      // draws arrow pointing up
      case TipDirection.down:
        return _getBottomRightPath(rect)
          // draw to the right of the arrow
          ..lineTo(
              min(
                  max(
                      targetCenter.dx + _arrowDecoration.baseWidth / 2,
                      rect.left +
                          _borderDecoration.radius +
                          _arrowDecoration.baseWidth),
                  rect.right - topRightRadius),
              rect.top)
          // draw to arrow tip
          ..lineTo(targetCenter.dx + _arrowDecoration.tipRadius,
              targetCenter.dy + _arrowDecoration.distanceFromCenter)
          // add to arrow tip radius
          ..arcToPoint(
            Offset(targetCenter.dx - _arrowDecoration.tipRadius,
                targetCenter.dy + _arrowDecoration.distanceFromCenter),
            clockwise: false,
            radius: Radius.circular(_arrowDecoration.tipRadius * 1.5),
          )
          // draw to the left of the arrow
          ..lineTo(
              max(
                  min(targetCenter.dx - _arrowDecoration.baseWidth / 2,
                      rect.right - topLeftRadius - _arrowDecoration.baseWidth),
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
                      targetCenter.dx + _arrowDecoration.baseWidth / 2,
                      rect.left +
                          bottomLeftRadius +
                          _arrowDecoration.baseWidth),
                  rect.right - bottomRightRadius),
              rect.bottom)
          // draw to arrow tip
          ..lineTo(targetCenter.dx + _arrowDecoration.tipRadius,
              targetCenter.dy - _arrowDecoration.distanceFromCenter)
          // add to arrow tip radius
          ..arcToPoint(
            Offset(targetCenter.dx - _arrowDecoration.tipRadius,
                targetCenter.dy - _arrowDecoration.distanceFromCenter),
            clockwise: true,
            radius: Radius.circular(_arrowDecoration.tipRadius * 1.5),
          )
          // draw to the left of the arrow
          ..lineTo(
              max(
                  min(
                      targetCenter.dx - _arrowDecoration.baseWidth / 2,
                      rect.right -
                          bottomRightRadius -
                          _arrowDecoration.baseWidth),
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
                      targetCenter.dy - _arrowDecoration.baseWidth / 2,
                      rect.bottom -
                          bottomRightRadius -
                          _arrowDecoration.baseWidth),
                  rect.top + topRightRadius))
          // draw to arrow tip
          ..lineTo(targetCenter.dx - _arrowDecoration.distanceFromCenter,
              targetCenter.dy - _arrowDecoration.tipRadius)
          // add to arrow tip radius
          ..arcToPoint(
            Offset(targetCenter.dx - _arrowDecoration.distanceFromCenter,
                targetCenter.dy + _arrowDecoration.tipRadius),
            clockwise: true,
            radius: Radius.circular(_arrowDecoration.tipRadius * 1.5),
          )
          // draw to the end of the arrow
          ..lineTo(
              rect.right,
              min(targetCenter.dy + _arrowDecoration.baseWidth / 2,
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
                      targetCenter.dy - _arrowDecoration.baseWidth / 2,
                      rect.bottom -
                          bottomLeftRadius -
                          _arrowDecoration.baseWidth),
                  rect.top + topLeftRadius))

          // draw to arrow tip
          ..lineTo(targetCenter.dx + _arrowDecoration.distanceFromCenter,
              targetCenter.dy - _arrowDecoration.tipRadius)
          // add to arrow tip radius
          ..arcToPoint(
            Offset(targetCenter.dx + _arrowDecoration.distanceFromCenter,
                targetCenter.dy + _arrowDecoration.tipRadius),
            clockwise: false,
            radius: Radius.circular(_arrowDecoration.tipRadius * 1.5),
          )
          //  draw to end of arrow
          ..lineTo(
              rect.left,
              min(targetCenter.dy + _arrowDecoration.baseWidth / 2,
                  rect.bottom - bottomLeftRadius))
          // draw to bottom left
          ..lineTo(rect.left, rect.bottom - bottomLeftRadius)
          // add bottom left corner
          ..arcToPoint(Offset(rect.left + bottomLeftRadius, rect.bottom),
              radius: Radius.circular(bottomLeftRadius), clockwise: false);
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
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _borderDecoration.width;

    // if the position snaps, we need to overlap the border with the background color
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
      backgroundColor: backgroundColor,
      targetCenter: targetCenter,
      borderDecoration: _borderDecoration,
      position: position,
      arrowDecoration: _arrowDecoration,
    );
  }
}
