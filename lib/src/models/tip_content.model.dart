import 'package:flutter/material.dart';
import 'package:super_tooltip/src/models/enums/public_enums.dart';
import 'package:super_tooltip/super_tooltip.dart';

class TipContent {
  const TipContent({
    required this.child,
    this.margin = const EdgeInsets.all(16),
    this.position = const TipPosition.side(TipDirection.down),
    this.backgroundColor = Colors.white,
  });

  /// The content of the Tooltip
  final Widget child;

  final EdgeInsets margin;

  /// positions the Tooltip screen
  final TipPosition position;
  final Color backgroundColor;
}
