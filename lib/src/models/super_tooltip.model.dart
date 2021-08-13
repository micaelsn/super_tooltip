import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:super_tooltip/src/models/close_tip_object.model.dart';

import '../enums.dart';
import 'models.dart';

typedef OnCloseCallback = void Function();

/// Super flexible Tooltip class that allows you to show any content
/// inside a Tooltip in the overlay of the screen.
///
class SuperTooltip {
  SuperTooltip({
    required this.content, // The contents of the tooltip.
    this.onClose,
    this.constraints,
    this.margin = 16.0,
    this.closeTipObject = const CloseTipObject.inside(),
    this.elevation = 1,
    this.borderDecoration,
    this.arrowDecoration = const ArrowDecoration(),
    this.background,
    this.contentBackgroundColor = Colors.white,
    this.animationDuration = const Duration(milliseconds: 400),
    this.tipPosition = const TipPosition.side(TipDirection.down),
  })  : assert((constraints?.maxWidth ?? double.infinity) >=
            (constraints?.minWidth ?? 0.0)),
        assert((constraints?.maxHeight ?? double.infinity) >=
            (constraints?.minHeight ?? 0.0)),
        boxShadow = null;

  SuperTooltip.shadow({
    required this.content, // The contents of the tooltip.
    this.onClose,
    this.constraints,
    this.margin = 16.0,
    this.closeTipObject = const CloseTipObject.inside(),
    this.boxShadow,
    this.borderDecoration,
    this.arrowDecoration = const ArrowDecoration(),
    this.background,
    this.contentBackgroundColor = Colors.white,
    this.animationDuration = const Duration(milliseconds: 400),
    this.tipPosition = const TipPosition.side(TipDirection.down),
  })  : assert((constraints?.maxWidth ?? double.infinity) >=
            (constraints?.minWidth ?? 0.0)),
        assert((constraints?.maxHeight ?? double.infinity) >=
            (constraints?.minHeight ?? 0.0)),
        elevation = 0;

  /// optional handler that gets called when the Tooltip is closed
  final OnCloseCallback? onClose;

  /// The content of the Tooltip
  final Widget content;

  /// [constraints] optional size constraints.
  /// If a constraint is not set the size will ajust to the content
  final TipConstraints? constraints;

  /// The minium padding from the Tooltip to the screen limits
  final double margin;

  /// [tipPosition] positions the Tooltip screen
  final TipPosition tipPosition;

  /// [boxShadow] defines the tooltip shadow
  final List<BoxShadow>? boxShadow;

  final CloseTipObject closeTipObject;

  /// The z-coordinate at which to place the tooltip when open.
  ///
  /// The following elevations have defined shadows: 1, 2, 3, 4, 6, 8, 9, 12,
  /// 16, and 24.
  ///
  /// See [kElevationToShadow].
  final int elevation;

  /// the decoration applied to the border of the Tooltip
  final BorderDecoration? borderDecoration;

  /// The decoration applied to the arrow
  final ArrowDecoration arrowDecoration;

  /// The background of the Tooltip
  final TipBackground? background;

  final Color contentBackgroundColor;
  final Duration animationDuration;
}
