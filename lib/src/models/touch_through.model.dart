import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../enums.dart';

typedef TouchThroughPosition = Offset Function(Offset);

///
/// By default touching the surrounding of the Tooltip closes the tooltip.
/// you can define a rectangle area where the background is completely transparent
/// and the widgets below react to touch
class TouchThrough {
  // ignore: unused_element
  const TouchThrough._({
    required this.area,
    this.shape = ClipAreaShape.oval,
    this.borderRadius = 5.0,
    this.position,
    this.isCustom = false,
  });

  TouchThrough.oval({
    double height = 120,
    double width = 200,
  })  : area = Rect.fromCenter(
          center: const Offset(0, 0),
          width: width,
          height: height,
        ),
        borderRadius = 0,
        isCustom = false,
        position = null,
        shape = ClipAreaShape.oval;

  TouchThrough.circle({
    double size = 200,
  })  : area = Rect.fromCenter(
          center: const Offset(0, 0),
          width: size,
          height: size,
        ),
        borderRadius = 0,
        isCustom = false,
        position = null,
        shape = ClipAreaShape.oval;

  TouchThrough.rect({
    double height = 120,
    double width = 200,
    this.borderRadius = 5,
  })  : area = Rect.fromCenter(
          center: const Offset(0, 0),
          width: width,
          height: height,
        ),
        isCustom = false,
        position = null,
        shape = ClipAreaShape.rectangle;

  TouchThrough.square({
    double size = 200,
    this.borderRadius = 5,
  })  : area = Rect.fromCenter(
          center: const Offset(0, 0),
          width: size,
          height: size,
        ),
        isCustom = false,
        position = null,
        shape = ClipAreaShape.oval;

  TouchThrough.custom({
    required this.area,
    this.borderRadius = 5,
    this.shape = ClipAreaShape.rectangle,
  })  : isCustom = true,
        position = null;

  final Rect area;

  /// The shape of the [area].
  final ClipAreaShape shape;

  /// If [shape] is [ClipAreaShape.rectangle] you can define a border radius
  final double borderRadius;

  final TouchThroughPosition? position;

  final bool isCustom;
}
