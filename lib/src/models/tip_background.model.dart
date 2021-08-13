import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'touch_through.model.dart';

class TipBackground {
  const TipBackground({
    this.color = Colors.white,
    this.outsideColor = const Color.fromARGB(50, 255, 255, 255),
    this.dismissible = true,
    this.absorbPointerEvents = true,
    this.touchThrough,
  });

  /// The backgroundcolor of the Tooltip
  final Color color;

  /// The color of the rest of the overlay surrounding the Tooltip.
  /// typically a translucent color.
  final Color outsideColor;

  /// Allow the tooltip to be dismissed tapping outside
  final bool dismissible;

  /// Block pointer actions or pass them through background
  final bool absorbPointerEvents;

  /// By default touching the surrounding of the Tooltip closes the tooltip.
  /// you can define a rectangle area where the background is completely transparent
  /// and the widgets below react to touch
  final TouchThrough? touchThrough;
}
