import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../enums.dart';

typedef TouchThroughPosition = Offset Function(Offset);

///
/// By default touching the surrounding of the Tooltip closes the tooltip.
/// you can define a rectangle area where the background is completely transparent
/// and the widgets below react to touch
class TouchThrough {
  const TouchThrough._({
    required this.area,
    this.shape = ClipAreaShape.oval,
    this.borderRadius = 5.0,
    this.position,
    this.isCustom = false,
  });

  factory TouchThrough.oval({
    SizedBox? area,
    TouchThroughPosition? position,
  }) {
    return TouchThrough._(
      area: Rect.fromCenter(
        center: const Offset(0, 0),
        width: area?.width ?? 0,
        height: area?.height ?? 0,
      ),
      shape: ClipAreaShape.oval,
      position: position,
    );
  }

  factory TouchThrough.rect({
    SizedBox? area,
    double? borderRadius,
    TouchThroughPosition? position,
  }) {
    return TouchThrough._(
      area: Rect.fromCenter(
        center: const Offset(0, 0),
        width: area?.width ?? 0,
        height: area?.height ?? 0,
      ),
      shape: ClipAreaShape.rectangle,
      borderRadius: borderRadius ?? 5,
      position: position,
    );
  }

  factory TouchThrough.custom({
    required Rect area,
    double? borderRadius,
    TouchThroughPosition? position,
  }) {
    return TouchThrough._(
      area: area,
      shape: ClipAreaShape.rectangle,
      borderRadius: borderRadius ?? 5,
      position: position,
      isCustom: true,
    );
  }

  final Rect area;

  ///
  /// The shape of the [area].
  final ClipAreaShape shape;

  ///
  /// If [shape] is [ClipAreaShape.rectangle] you can define a border radius
  final double borderRadius;

  final TouchThroughPosition? position;

  final bool isCustom;
}
