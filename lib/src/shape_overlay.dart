import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:super_tooltip/src/models/enums/private_enums.dart';

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
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

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

    final _rect = clipRect;
    if (_rect == null) {
      return null;
    } else if (clipAreaShape == ClipAreaShape.oval) {
      exclusion = Path()..addOval(_rect);
    } else {
      exclusion = Path()
        ..moveTo(_rect.left + clipAreaCornerRadius, _rect.top)
        ..lineTo(_rect.right - clipAreaCornerRadius, _rect.top)
        ..arcToPoint(Offset(_rect.right, _rect.top + clipAreaCornerRadius),
            radius: Radius.circular(clipAreaCornerRadius))
        ..lineTo(_rect.right, _rect.bottom - clipAreaCornerRadius)
        ..arcToPoint(Offset(_rect.right - clipAreaCornerRadius, _rect.bottom),
            radius: Radius.circular(clipAreaCornerRadius))
        ..lineTo(_rect.left + clipAreaCornerRadius, _rect.bottom)
        ..arcToPoint(Offset(_rect.left, _rect.bottom - clipAreaCornerRadius),
            radius: Radius.circular(clipAreaCornerRadius))
        ..lineTo(_rect.left, _rect.top + clipAreaCornerRadius)
        ..arcToPoint(Offset(_rect.left + clipAreaCornerRadius, _rect.top),
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
