import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';

class TipContent {
  const TipContent({
    required this.child,
    this.position = const TipPosition.side(TipDirection.down),
    this.backgroundColor = Colors.white,
  });

  /// The content of the Tooltip
  final Widget child;

  /// positions the Tooltip screen
  final TipPosition position;
  final Color backgroundColor;
}
