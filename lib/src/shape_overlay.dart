import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'enums.dart';

class ShapeOverlay extends ShapeBorder {
  ShapeOverlay(
    this.clipRect,
    this.clipAreaShape,
    this.clipAreaCornerRadius,
    this.outsideBackgroundColor,
  );

  final Rect? clipRect;
  final Color outsideBackgroundColor;
  final ClipAreaShape clipAreaShape;
  final double clipAreaCornerRadius;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10.0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addOval(clipRect!);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final outer = Path()..addRect(rect);

    final exclusion = getExclusion();
    if (exclusion == null) {
      return outer;
    } else {
      return Path.combine(ui.PathOperation.difference, outer, exclusion);
    }
  }

  Path? getExclusion() {
    Path exclusion;
    if (clipRect == null) {
      return null;
    } else if (clipAreaShape == ClipAreaShape.oval) {
      exclusion = Path()..addOval(clipRect!);
    } else {
      exclusion = Path()
        ..moveTo(clipRect!.left + clipAreaCornerRadius, clipRect!.top)
        ..lineTo(clipRect!.right - clipAreaCornerRadius, clipRect!.top)
        ..arcToPoint(
            Offset(clipRect!.right, clipRect!.top + clipAreaCornerRadius),
            radius: Radius.circular(clipAreaCornerRadius))
        ..lineTo(clipRect!.right, clipRect!.bottom - clipAreaCornerRadius)
        ..arcToPoint(
            Offset(clipRect!.right - clipAreaCornerRadius, clipRect!.bottom),
            radius: Radius.circular(clipAreaCornerRadius))
        ..lineTo(clipRect!.left + clipAreaCornerRadius, clipRect!.bottom)
        ..arcToPoint(
            Offset(clipRect!.left, clipRect!.bottom - clipAreaCornerRadius),
            radius: Radius.circular(clipAreaCornerRadius))
        ..lineTo(clipRect!.left, clipRect!.top + clipAreaCornerRadius)
        ..arcToPoint(
            Offset(clipRect!.left + clipAreaCornerRadius, clipRect!.top),
            radius: Radius.circular(clipAreaCornerRadius))
        ..close();
    }
    return exclusion;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    canvas.drawPath(
        getOuterPath(rect), Paint()..color = outsideBackgroundColor);
  }

  @override
  ShapeBorder scale(double t) {
    return ShapeOverlay(
      clipRect,
      clipAreaShape,
      clipAreaCornerRadius,
      outsideBackgroundColor,
    );
  }
}
