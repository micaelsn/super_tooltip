import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:super_tooltip/src/models/tip_constraints.model.dart';

import 'animation_wrapper.dart';
import 'bubble_shape.dart';
import 'enums.dart';
import 'models/models.dart';
import 'models/super_tooltip.model.dart';
import 'pop_up_balloon_layout_delegate.dart';
import 'shape_overlay.dart';

typedef TargetBuilder = Widget Function(BuildContext, ShowHandler);
typedef ShowHandler = void Function(BuildContext targetContext,
    {OverlayState? overlay});

var _isOpen = false;

class SuperTooltipBuilder extends StatelessWidget {
  SuperTooltipBuilder({
    required Key key,
    required this.targetBuilder,
    required this.tooltip,
  }) : super(key: key);

  final TargetBuilder targetBuilder;
  final SuperTooltip tooltip;

  final _overlays = <OverlayEntry>[];

  void _close() {
    if (tooltip.onClose != null) {
      tooltip.onClose!();
    }

    for (final overlay in _overlays) {
      overlay.remove();
    }
    _overlays.clear();
    _isOpen = false;
  }

  void _show(BuildContext targetContext, {OverlayState? overlay}) {
    if (_isOpen) {
      _close();
    }
    final renderBox = targetContext.findRenderObject() as RenderBox;
    final _overlay = overlay ??= Overlay.of(targetContext);
    OverlayEntry? _backgroundOverlay;
    final overlayRenderBox = _overlay!.context.findRenderObject() as RenderBox?;

    final _targetCenter = renderBox.localToGlobal(
        renderBox.size.center(Offset.zero),
        ancestor: overlayRenderBox);

    // Create the background below the popup including the clipArea.
    if (tooltip.background.containsOverlay) {
      _backgroundOverlay = OverlayEntry(
        builder: (context) => SuperTooltipBackground(
          targetCenter: _targetCenter,
          background: tooltip.background,
          close: _close,
        ),
      );
    }

    if (_backgroundOverlay != null) {
      _overlays.add(_backgroundOverlay);
    }
    final _balloonOverlay = OverlayEntry(
      builder: (context) => _SuperTooltip(
        tooltip: tooltip,
        targetCenter: _targetCenter,
        targetSize: overlayRenderBox?.size,
        close: _close,
      ),
    );

    _overlays.add(_balloonOverlay);

    _overlay.insertAll(_overlays);
    _isOpen = true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // If the tooltip is open we don't pop the page on a backbutton press
        // but close the ToolTip
        if (_isOpen) {
          _close();
          return false;
        }
        return true;
      },
      child: targetBuilder(
        context,
        _show,
      ),
    );
  }
}

class _SuperTooltip extends StatefulWidget {
  _SuperTooltip({
    Key? key,
    required this.tooltip,
    required this.targetCenter,
    required this.targetSize,
    required this.close,
  }) : super(key: key);

  final SuperTooltip tooltip;
  final Offset targetCenter;
  final Size? targetSize;
  final OnCloseCallback close;

  @override
  __SuperTooltipState createState() => __SuperTooltipState();
}

class __SuperTooltipState extends State<_SuperTooltip> {
  EdgeInsets _getBalloonContainerMargin() {
    final top = (widget.tooltip.closeButtonPosition?.isOutside ?? false)
        ? (widget.tooltip.closeWidget.preferredSize.height) + 5
        : 0.0;

    final distanceAway = widget.tooltip.pointerDecoration.distanceAway;

    switch (widget.tooltip.popupDirection) {
      case TooltipDirection.down:
        return EdgeInsets.only(
          top: distanceAway,
        );

      case TooltipDirection.up:
        return EdgeInsets.only(bottom: distanceAway, top: top);

      case TooltipDirection.left:
        return EdgeInsets.only(right: distanceAway, top: top);

      case TooltipDirection.right:
        return EdgeInsets.only(left: distanceAway, top: top);

      default:
        throw AssertionError(widget.tooltip.popupDirection);
    }
  }

  @override
  Widget build(BuildContext context) {
    var _left = widget.tooltip.tipPosition.left,
        _right = widget.tooltip.tipPosition.right,
        _top = widget.tooltip.tipPosition.top,
        _bottom = widget.tooltip.tipPosition.bottom;
    var _popupDirection = widget.tooltip.popupDirection;

    /// Handling snap far away feature.
    if (widget.tooltip.tipPosition.snapsVertical) {
      _left = 0.0;
      _right = 0.0;
      if ((widget.targetCenter.dy) >
          (widget.targetSize?.center(Offset.zero).dy ?? 0)) {
        _popupDirection = TooltipDirection.up;
        _top = 0.0;
      } else {
        _popupDirection = TooltipDirection.down;
        _bottom = 0.0;
      }
    }
    // Only one of of them is possible, and vertical has higher priority.
    else if (widget.tooltip.tipPosition.snapsHorizontal) {
      _top = 0.0;
      _bottom = 0.0;
      if (widget.targetCenter.dx <
          (widget.targetSize?.center(Offset.zero).dx ?? 0)) {
        _popupDirection = TooltipDirection.right;
        _right = 0.0;
      } else {
        _popupDirection = TooltipDirection.left;
        _left = 0.0;
      }
    }

    return AnimationWrapper(
      builder: (context, opacity) => AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: opacity,
        child: Center(
          child: CustomSingleChildLayout(
            delegate: PopupBalloonLayoutDelegate(
              direction: _popupDirection,
              targetCenter: widget.targetCenter,
              tipConstraints: TipConstraints(
                minWidth: widget.tooltip.constraints?.minWidth,
                maxWidth: widget.tooltip.tipPosition.snapsHorizontal
                    ? null
                    : widget.tooltip.constraints?.maxWidth,
                minHeight: widget.tooltip.constraints?.minHeight,
                maxHeight: widget.tooltip.tipPosition.snapsVertical
                    ? null
                    : widget.tooltip.constraints?.maxHeight,
              ),
              outSidePadding: widget.tooltip.minimumOutSidePadding,
              position: TipPosition.fromLTRB(
                _left,
                _top,
                _right,
                _bottom,
              ),
            ),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                Positioned(
                  child: Padding(
                    padding: _getBalloonContainerMargin(),
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                          color: widget.tooltip.background.color,
                          shadows: widget.tooltip.boxShadow,
                          shape: BubbleShape(
                            direction: widget.tooltip.popupDirection,
                            targetCenter: widget.targetCenter,
                            borderDecoration: widget.tooltip.borderDecoration,
                            pointerDecoration: widget.tooltip.pointerDecoration,
                            position: TipPosition.fromLTRB(
                              _left,
                              _top,
                              _right,
                              _bottom,
                            ),
                          )),
                      child: widget.tooltip.content,
                    ),
                  ),
                ),
                Builder(
                  builder: (context) {
                    const internalClickAreaPadding = 2.0;
                    final closePosition = widget.tooltip.closeButtonPosition;

                    if (closePosition == null) {
                      return const SizedBox();
                    }

                    double? right;
                    double? top;

                    switch (widget.tooltip.popupDirection) {
                      //
                      // LEFT: -------------------------------------
                      case TooltipDirection.left:
                        right =
                            widget.tooltip.pointerDecoration.distanceAway + 3.0;
                        if (closePosition.isInside) {
                          top = 2.0;
                        } else if (closePosition.isOutside) {
                          top = 0.0;
                        } else
                          throw AssertionError(closePosition);
                        break;

                      // RIGHT/UP: ---------------------------------
                      case TooltipDirection.right:
                      case TooltipDirection.up:
                        right = 5.0;
                        if (closePosition.isInside) {
                          top = 2.0;
                        } else if (closePosition.isOutside) {
                          top = 0.0;
                        } else
                          throw AssertionError(closePosition);
                        break;

                      // DOWN: -------------------------------------
                      case TooltipDirection.down:
                        // If this value gets negative the Shadow gets clipped. The problem occurs is arrowlength + arrowTipDistance
                        // is smaller than _outSideCloseButtonPadding which would mean arrowLength would need to be increased if the button is ouside.
                        right = 2.0;
                        if (closePosition.isInside) {
                          top = widget.tooltip.pointerDecoration.distanceAway +
                              2.0;
                        } else if (closePosition.isOutside) {
                          top = 0.0;
                        } else
                          throw AssertionError(closePosition);
                        break;
                    }

                    return Positioned(
                        right: right,
                        top: top,
                        child: GestureDetector(
                          onTap: widget.close,
                          child: Material(
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  internalClickAreaPadding),
                              child: GestureDetector(
                                onTap: widget.close,
                                child: AbsorbPointer(
                                  absorbing: true,
                                  child: widget.tooltip.closeWidget,
                                ),
                              ),
                            ),
                          ),
                        ));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SuperTooltipBackground extends StatelessWidget {
  const SuperTooltipBackground({
    Key? key,
    required this.targetCenter,
    required this.background,
    required this.close,
  }) : super(key: key);

  final Offset targetCenter;
  final TipBackground background;
  final OnCloseCallback close;

  @override
  Widget build(BuildContext context) {
    late Widget backgroundContent;

    final shapeOverlay = ShapeOverlay(
      Rect.fromLTWH(
        targetCenter.dx - (background.touchThrough?.area?.left ?? 0),
        targetCenter.dy - (background.touchThrough?.area?.top ?? 0),
        (background.touchThrough?.area?.width ?? 0),
        (background.touchThrough?.area?.height ?? 0),
      ),
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
    return AnimationWrapper(
      builder: (context, opacity) => AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 600),
        child: backgroundContent,
      ),
    );
  }
}
