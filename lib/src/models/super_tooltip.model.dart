import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
    TipPosition? tipPosition,
    this.minimumOutSidePadding = 20.0,
    this.closeButtonPosition = CloseButtonPosition.inside,
    this.boxShadow,
    this.borderDecoration,
    this.pointerDecoration = const PointerDecoration(),
    PreferredSize? closeWidget,
    TipBackground? background,
  })  : assert((constraints?.maxWidth ?? double.infinity) >=
            (constraints?.minWidth ?? 0.0)),
        assert((constraints?.maxHeight ?? double.infinity) >=
            (constraints?.minHeight ?? 0.0)),
        tipPosition = tipPosition ?? TipPosition.snapTo(SnapToSpace.vertical),
        background = background ?? TipBackground(),
        closeWidget = closeWidget ??
            const PreferredSize(
              preferredSize: Size.fromHeight(35),
              child: Icon(Icons.close),
            );

  ///
  /// The content of the Tooltip
  final Widget content;

  ///
  /// optional handler that gets called when the Tooltip is closed
  final OnCloseCallback? onClose;

  ///
  /// [constraints] optional size constraints.
  /// If a constraint is not set the size will ajust to the content
  final BoxConstraints? constraints;

  ///
  /// The minium padding from the Tooltip to the screen limits
  final double minimumOutSidePadding;

  /// [tipPosition] positions the Tooltip screen
  final TipPosition tipPosition;

  ///
  /// The position of the close button, set to null to hide the close button
  final CloseButtonPosition? closeButtonPosition;

  ///
  /// [boxShadow] defines the tooltip shadow
  final List<BoxShadow>? boxShadow;

  ///
  /// the decoration applied to the border of the Tooltip
  final BorderDecoration? borderDecoration;

  ///
  /// The decoration applied to the pointer
  final PointerDecoration pointerDecoration;

  ///
  /// The widget that is used to close the Tooltip
  ///
  /// uses Icon(Icons.close) by default
  final PreferredSize closeWidget;

  ///
  /// The background of the Tooltip
  final TipBackground background;
}
