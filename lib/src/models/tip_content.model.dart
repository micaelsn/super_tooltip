import 'package:flutter/material.dart';
import 'package:super_tooltip/src/models/enums/public_enums.dart';
import 'package:super_tooltip/super_tooltip.dart';

class TipContent {
  const TipContent({
    required this.child,
    this.margin = const EdgeInsets.all(16),
    this.position = const TipPosition.side(TipDirection.down),
    this.backgroundColor = Colors.white,
  })  : sigmaX = 0,
        sigmaY = 0,
        blurBackground = false;

  const TipContent.blur({
    required this.child,
    this.margin = const EdgeInsets.all(16),
    this.position = const TipPosition.side(TipDirection.down),
    this.backgroundColor = Colors.white,
    this.sigmaX = 3,
    this.sigmaY = 3,
  }) : blurBackground = true;

  /// The content of the Tooltip
  final Widget child;

  final EdgeInsets margin;

  /// positions the Tooltip screen
  final TipPosition position;
  final Color backgroundColor;
  final double sigmaX, sigmaY;
  final bool blurBackground;
}
