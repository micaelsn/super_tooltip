import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'animation_wrapper.dart';
import 'bubble_shape.dart';
import 'enums.dart';
import 'models/models.dart';
import 'pop_up_balloon_layout_delegate.dart';
import 'shape_overlay.dart';

typedef OnCloseCallback = void Function();

/// Super flexible Tooltip class that allows you to show any content
/// inside a Tooltip in the overlay of the screen.
///
class SuperTooltip {
  SuperTooltip({
    this.key,
    required this.content, // The contents of the tooltip.
    required this.popupDirection,
    this.onClose,
    this.constraints,
    TipPosition? tipPosition,
    this.minimumOutSidePadding = 20.0,
    this.closeButtonPosition = CloseButtonPosition.inside,
    this.boxShadow,
    this.borderDecoration,
    this.pointerDecoration = const PointerDecoration(),
    this.closeWidget,
    TipBackground? background,
  })  : assert((constraints?.maxWidth ?? double.infinity) >=
            (constraints?.minWidth ?? 0.0)),
        assert((constraints?.maxHeight ?? double.infinity) >=
            (constraints?.minHeight ?? 0.0)),
        tipPosition = tipPosition ?? TipPosition.snapTo(SnapToSpace.vertical),
        background = background ?? TipBackground();

  /// Allows to access the close button for UI Testing
  static Key closeButtonKey = const Key('CloseButtonKey');

  final Key? key;

  /// Signals if the Tooltip is visible at the moment
  var isOpen = false;

  ///
  /// The content of the Tooltip
  final Widget content;

  ///
  /// The direcion in which the tooltip should open
  TooltipDirection popupDirection;

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
  /// The position of the close button
  final CloseButtonPosition closeButtonPosition;

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
  /// if null, the Tooltip will not have a close button
  final PreferredSize? closeWidget;

  ///
  /// The background of the Tooltip
  final TipBackground background;

  Offset? _targetCenter;
  OverlayEntry? _backGroundOverlay;
  OverlayEntry? _ballonOverlay;

  ///
  /// Removes the Tooltip from the overlay
  void close() {
    if (onClose != null) {
      onClose!();
    }

    _ballonOverlay!.remove();
    _backGroundOverlay?.remove();
    isOpen = false;
  }

  ///
  /// Displays the tooltip
  /// The center of [targetContext] is used as target of the arrow
  ///
  /// Uses [overlay] to show tooltip or [targetContext]'s overlay if [overlay] is null
  void show(BuildContext targetContext, {OverlayState? overlay}) {
    final renderBox = targetContext.findRenderObject() as RenderBox;
    overlay ??= Overlay.of(targetContext)!;
    final overlayRenderBox = overlay.context.findRenderObject() as RenderBox?;

    _targetCenter = renderBox.localToGlobal(renderBox.size.center(Offset.zero),
        ancestor: overlayRenderBox);

    // Create the background below the popup including the clipArea.
    if (background.containsOverlay) {
      late Widget backgroundContent;

      final shapeOverlay = ShapeOverlay(
        background.touchThrough?.area,
        background.touchThrough?.shape ?? ClipAreaShape.rectangle,
        background.touchThrough?.borderRadius ?? 0,
        background.outsideColor,
      );
      final backgroundDecoration =
          DecoratedBox(decoration: ShapeDecoration(shape: shapeOverlay));

      if (background.dismissible && background.absorbPointerEvents) {
        backgroundContent = GestureDetector(
          onTap: close,
          child: backgroundDecoration,
        );
      } else if (background.dismissible && !background.absorbPointerEvents) {
        backgroundContent = Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            if (!(shapeOverlay.getExclusion()?.contains(event.localPosition) ??
                false)) {
              close();
            }
          },
          child: IgnorePointer(child: backgroundDecoration),
        );
      } else if (!background.dismissible && background.absorbPointerEvents) {
        backgroundContent = backgroundDecoration;
      } else if (!background.dismissible && !background.absorbPointerEvents) {
        backgroundContent = IgnorePointer(child: backgroundDecoration);
      } else {
        backgroundContent = backgroundDecoration;
      }

      _backGroundOverlay = OverlayEntry(
          builder: (context) => AnimationWrapper(
                builder: (context, opacity) => AnimatedOpacity(
                  opacity: opacity,
                  duration: const Duration(milliseconds: 600),
                  child: backgroundContent,
                ),
              ));
    }

    var _left = tipPosition.left,
        _right = tipPosition.right,
        _top = tipPosition.top,
        _bottom = tipPosition.bottom;

    /// Handling snap far away feature.
    if (tipPosition.snapsVertical) {
      _left = 0.0;
      _right = 0.0;
      if (_targetCenter!.dy > overlayRenderBox!.size.center(Offset.zero).dy) {
        popupDirection = TooltipDirection.up;
        _top = 0.0;
      } else {
        popupDirection = TooltipDirection.down;
        _bottom = 0.0;
      }
    }
    // Only one of of them is possible, and vertical has higher priority.
    else if (tipPosition.snapsHorizontal) {
      _top = 0.0;
      _bottom = 0.0;
      if (_targetCenter!.dx < overlayRenderBox!.size.center(Offset.zero).dx) {
        popupDirection = TooltipDirection.right;
        _right = 0.0;
      } else {
        popupDirection = TooltipDirection.left;
        _left = 0.0;
      }
    }

    _ballonOverlay = OverlayEntry(
      builder: (context) => AnimationWrapper(
        builder: (context, opacity) => AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: opacity,
          child: Center(
            child: CustomSingleChildLayout(
              delegate: PopupBallonLayoutDelegate(
                popupDirection: popupDirection,
                targetCenter: _targetCenter,
                minWidth: constraints?.minWidth,
                maxWidth:
                    tipPosition.snapsHorizontal ? null : constraints?.maxWidth,
                minHeight: constraints?.minHeight,
                maxHeight:
                    tipPosition.snapsVertical ? null : constraints?.maxHeight,
                outSidePadding: minimumOutSidePadding,
                top: _top,
                bottom: _bottom,
                left: _left,
                right: _right,
              ),
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  Padding(
                    padding: _getBalloonContainerMargin(),
                    child: DecoratedBox(
                      key: key,
                      decoration: ShapeDecoration(
                          color: background.color,
                          shadows: boxShadow,
                          shape: BubbleShape(
                            direction: popupDirection,
                            targetCenter: _targetCenter,
                            borderDecoration: borderDecoration,
                            pointerDecoration: pointerDecoration,
                            position: TipPosition.fromLTRB(
                              _left,
                              _top,
                              _right,
                              _bottom,
                            ),
                          )),
                      child: content,
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      const internalClickAreaPadding = 2.0;

                      if (closeWidget == null) {
                        return const SizedBox();
                      }

                      double right;
                      double top;

                      switch (popupDirection) {
                        //
                        // LEFT: -------------------------------------
                        case TooltipDirection.left:
                          right = pointerDecoration.distanceAway + 3.0;
                          if (closeButtonPosition ==
                              CloseButtonPosition.inside) {
                            top = 2.0;
                          } else if (closeButtonPosition ==
                              CloseButtonPosition.outside) {
                            top = 0.0;
                          } else
                            throw AssertionError(closeButtonPosition);
                          break;

                        // RIGHT/UP: ---------------------------------
                        case TooltipDirection.right:
                        case TooltipDirection.up:
                          right = 5.0;
                          if (closeButtonPosition ==
                              CloseButtonPosition.inside) {
                            top = 2.0;
                          } else if (closeButtonPosition ==
                              CloseButtonPosition.outside) {
                            top = 0.0;
                          } else
                            throw AssertionError(closeButtonPosition);
                          break;

                        // DOWN: -------------------------------------
                        case TooltipDirection.down:
                          // If this value gets negative the Shadow gets clipped. The problem occurs is arrowlength + arrowTipDistance
                          // is smaller than _outSideCloseButtonPadding which would mean arrowLength would need to be increased if the button is ouside.
                          right = 2.0;
                          if (closeButtonPosition ==
                              CloseButtonPosition.inside) {
                            top = pointerDecoration.distanceAway + 2.0;
                          } else if (closeButtonPosition ==
                              CloseButtonPosition.outside) {
                            top = 0.0;
                          } else
                            throw AssertionError(closeButtonPosition);
                          break;
                      }

                      return Positioned(
                          right: right,
                          top: top,
                          child: GestureDetector(
                            onTap: close,
                            child: Container(
                              padding: const EdgeInsets.all(
                                  internalClickAreaPadding),
                              color: Colors.transparent,
                              child: closeWidget,
                            ),
                          ));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final overlays = <OverlayEntry>[];

    if (background.containsOverlay) {
      overlays.add(_backGroundOverlay!);
    }
    overlays.add(_ballonOverlay!);

    overlay.insertAll(overlays);
    isOpen = true;
  }

  EdgeInsets _getBalloonContainerMargin() {
    final top = (closeButtonPosition == CloseButtonPosition.outside)
        ? (closeWidget?.preferredSize.height ?? 0) + 5
        : 0.0;

    switch (popupDirection) {
      case TooltipDirection.down:
        return EdgeInsets.only(
          top: pointerDecoration.distanceAway,
        );

      case TooltipDirection.up:
        return EdgeInsets.only(
            bottom: pointerDecoration.distanceAway, top: top);

      case TooltipDirection.left:
        return EdgeInsets.only(right: pointerDecoration.distanceAway, top: top);

      case TooltipDirection.right:
        return EdgeInsets.only(left: pointerDecoration.distanceAway, top: top);

      default:
        throw AssertionError(popupDirection);
    }
  }
}
