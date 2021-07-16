import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';
import 'models/absolute_position.model.dart';
import 'models/border_decoration.model.dart';
import 'models/pointer_decoration.model.dart';

class BubbleShape extends ShapeBorder {
  BubbleShape({
    required this.direction,
    required this.targetCenter,
    PointerDecoration? pointerDecoration,
    BorderDecoration? borderDecoration,
    this.position,
  })  : _borderDecoration = borderDecoration ?? const BorderDecoration(),
        _pointerDecoration = pointerDecoration ?? const PointerDecoration();

  final TooltipDirection direction;
  final Offset targetCenter;
  final PointerDecoration _pointerDecoration;
  final BorderDecoration _borderDecoration;
  final TipPosition? position;

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
    //
    late double topLeftRadius,
        topRightRadius,
        bottomLeftRadius,
        bottomRightRadius;

    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom - bottomLeftRadius)
        ..lineTo(rect.left, rect.top + topLeftRadius)
        ..arcToPoint(Offset(rect.left + topLeftRadius, rect.top),
            radius: Radius.circular(topLeftRadius))
        ..lineTo(rect.right - topRightRadius, rect.top)
        ..arcToPoint(Offset(rect.right, rect.top + topRightRadius),
            radius: Radius.circular(topRightRadius), clockwise: true);
    }

    Path _getBottomRightPath(Rect rect) {
      return Path()
        ..moveTo(rect.left + bottomLeftRadius, rect.bottom)
        ..lineTo(rect.right - bottomRightRadius, rect.bottom)
        ..arcToPoint(Offset(rect.right, rect.bottom - bottomRightRadius),
            radius: Radius.circular(bottomRightRadius), clockwise: false)
        ..lineTo(rect.right, rect.top + topRightRadius)
        ..arcToPoint(Offset(rect.right - topRightRadius, rect.top),
            radius: Radius.circular(topRightRadius), clockwise: false);
    }

    topLeftRadius = (position?.left == 0 || position?.top == 0)
        ? 0.0
        : _borderDecoration.radius;
    topRightRadius = (position?.right == 0 || position?.top == 0)
        ? 0.0
        : _borderDecoration.radius;
    bottomLeftRadius = (position?.left == 0 || position?.bottom == 0)
        ? 0.0
        : _borderDecoration.radius;
    bottomRightRadius = (position?.right == 0 || position?.bottom == 0)
        ? 0.0
        : _borderDecoration.radius;

    switch (direction) {
      case TooltipDirection.down:
        return _getBottomRightPath(rect)
          ..lineTo(
              min(
                  max(
                      targetCenter.dx + _pointerDecoration.baseWidth / 2,
                      rect.left +
                          _borderDecoration.radius +
                          _pointerDecoration.baseWidth),
                  rect.right - topRightRadius),
              rect.top)
          ..lineTo(
              targetCenter.dx,
              targetCenter.dy +
                  _pointerDecoration.height) // up to arrow tip   \
          ..lineTo(
              max(
                  min(
                      targetCenter.dx - _pointerDecoration.baseWidth / 2,
                      rect.right -
                          topLeftRadius -
                          _pointerDecoration.baseWidth),
                  rect.left + topLeftRadius),
              rect.top) //  down /

          ..lineTo(rect.left + topLeftRadius, rect.top)
          ..arcToPoint(Offset(rect.left, rect.top + topLeftRadius),
              radius: Radius.circular(topLeftRadius), clockwise: false)
          ..lineTo(rect.left, rect.bottom - bottomLeftRadius)
          ..arcToPoint(Offset(rect.left + bottomLeftRadius, rect.bottom),
              radius: Radius.circular(bottomLeftRadius), clockwise: false);

      case TooltipDirection.up:
        return _getLeftTopPath(rect)
          ..lineTo(rect.right, rect.bottom - bottomRightRadius)
          ..arcToPoint(Offset(rect.right - bottomRightRadius, rect.bottom),
              radius: Radius.circular(bottomRightRadius), clockwise: true)
          ..lineTo(
              min(
                  max(
                      targetCenter.dx + _pointerDecoration.baseWidth / 2,
                      rect.left +
                          bottomLeftRadius +
                          _pointerDecoration.baseWidth),
                  rect.right - bottomRightRadius),
              rect.bottom)

          // up to arrow tip   \
          ..lineTo(targetCenter.dx, targetCenter.dy - _pointerDecoration.height)

          //  down /
          ..lineTo(
              max(
                  min(
                      targetCenter.dx - _pointerDecoration.baseWidth / 2,
                      rect.right -
                          bottomRightRadius -
                          _pointerDecoration.baseWidth),
                  rect.left + bottomLeftRadius),
              rect.bottom)
          ..lineTo(rect.left + bottomLeftRadius, rect.bottom)
          ..arcToPoint(Offset(rect.left, rect.bottom - bottomLeftRadius),
              radius: Radius.circular(bottomLeftRadius), clockwise: true)
          ..lineTo(rect.left, rect.top + topLeftRadius)
          ..arcToPoint(Offset(rect.left + topLeftRadius, rect.top),
              radius: Radius.circular(topLeftRadius), clockwise: true);

      case TooltipDirection.left:
        return _getLeftTopPath(rect)
          ..lineTo(
              rect.right,
              max(
                  min(
                      targetCenter.dy - _pointerDecoration.baseWidth / 2,
                      rect.bottom -
                          bottomRightRadius -
                          _pointerDecoration.baseWidth),
                  rect.top + topRightRadius))
          ..lineTo(targetCenter.dx - _pointerDecoration.height,
              targetCenter.dy) // right to arrow tip   \
          //  left /
          ..lineTo(
              rect.right,
              min(targetCenter.dy + _pointerDecoration.baseWidth / 2,
                  rect.bottom - bottomRightRadius))
          ..lineTo(rect.right, rect.bottom - _borderDecoration.radius)
          ..arcToPoint(Offset(rect.right - bottomRightRadius, rect.bottom),
              radius: Radius.circular(bottomRightRadius), clockwise: true)
          ..lineTo(rect.left + bottomLeftRadius, rect.bottom)
          ..arcToPoint(Offset(rect.left, rect.bottom - bottomLeftRadius),
              radius: Radius.circular(bottomLeftRadius), clockwise: true);

      case TooltipDirection.right:
        return _getBottomRightPath(rect)
          ..lineTo(rect.left + topLeftRadius, rect.top)
          ..arcToPoint(Offset(rect.left, rect.top + topLeftRadius),
              radius: Radius.circular(topLeftRadius), clockwise: false)
          ..lineTo(
              rect.left,
              max(
                  min(
                      targetCenter.dy - _pointerDecoration.baseWidth / 2,
                      rect.bottom -
                          bottomLeftRadius -
                          _pointerDecoration.baseWidth),
                  rect.top + topLeftRadius))

          //left to arrow tip   /
          ..lineTo(
              targetCenter.dx + _pointerDecoration.baseWidth, targetCenter.dy)

          //  right \
          ..lineTo(
              rect.left,
              min(targetCenter.dy + _pointerDecoration.baseWidth / 2,
                  rect.bottom - bottomLeftRadius))
          ..lineTo(rect.left, rect.bottom - bottomLeftRadius)
          ..arcToPoint(Offset(rect.left + bottomLeftRadius, rect.bottom),
              radius: Radius.circular(bottomLeftRadius), clockwise: false);

      default:
        throw AssertionError(direction);
    }
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    var paint = Paint()
      ..color = _borderDecoration.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _borderDecoration.width;

    canvas.drawPath(getOuterPath(rect), paint);
    paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = _borderDecoration.width;

    if (position?.right == 0.0) {
      if (position?.top == 0.0 && position?.bottom == 0.0) {
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
    if (position?.left == 0.0) {
      if (position?.top == 0.0 && position?.bottom == 0.0) {
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
    if (position?.top == 0.0) {
      if (position?.left == 0.0 && position?.right == 0.0) {
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
    if (position?.bottom == 0.0) {
      if (position?.left == 0.0 && position?.right == 0.0) {
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
