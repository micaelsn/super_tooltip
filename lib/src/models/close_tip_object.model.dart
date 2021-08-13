import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';

class CloseTipObject {
  // ignore: unused_element
  const CloseTipObject._(
    this.position,
    this.child,
    this.height,
    this.width,
  );

  const CloseTipObject.inside({
    this.child,
    this.height = 32,
    this.width = 32,
  }) : position = ClosePosition.inside;

  const CloseTipObject.outside({
    this.child,
    this.height = 32,
    this.width = 32,
  }) : position = ClosePosition.outside;

  const CloseTipObject.none()
      : position = null,
        child = null,
        height = 0,
        width = 0;

  /// The position of the close button, set to null to hide the close button
  final ClosePosition? position;

  /// The widget that is used to close the Tooltip
  ///
  /// defaults to `Icon(Icons.close)`
  final Widget? child;

  /// The height of the close button
  ///
  /// defaults to 32
  final double height;

  /// The width of the close button
  ///
  /// defaults to 32
  final double width;
}
