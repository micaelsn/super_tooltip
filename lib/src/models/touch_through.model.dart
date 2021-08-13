import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../enums.dart';

///
/// By default touching the surrounding of the Tooltip closes the tooltip.
/// you can define a rectangle area where the background is completely transparent
/// and the widgets below react to touch
class TouchThrough {
  const TouchThrough._({
    this.shape = ClipAreaShape.oval,
    this.borderRadius = 5.0,
    this.area,
    this.centerArea = true,
  });

  factory TouchThrough.oval({Rect? area}) {
    return TouchThrough._(
      area: area,
      shape: ClipAreaShape.oval,
    );
  }
  factory TouchThrough.rect({
    Rect? area,
    double? borderRadius,
  }) {
    return TouchThrough._(
      area: area,
      shape: ClipAreaShape.rectangle,
      borderRadius: borderRadius ?? 5,
    );
  }

  final Rect? area;

  ///
  /// The shape of the [area].
  final ClipAreaShape shape;

  ///
  /// If [shape] is [ClipAreaShape.rectangle] you can define a border radius
  final double borderRadius;

  // TODO: [centerArea] is not used yet
  final bool centerArea;
}
