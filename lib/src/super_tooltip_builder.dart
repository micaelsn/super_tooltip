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
typedef ShowHandler = void Function({OverlayState? overlay});

var _isOpen = false;

class SuperTooltipBuilder extends StatefulWidget {
  SuperTooltipBuilder({
    required Key key,
    required this.targetBuilder,
    required this.tooltip,
  }) : super(key: key);

  final TargetBuilder targetBuilder;
  final SuperTooltip tooltip;

  @override
  _SuperTooltipBuilderState createState() => _SuperTooltipBuilderState();
}

class _SuperTooltipBuilderState extends State<SuperTooltipBuilder> {
  final _overlays = <OverlayEntry>[];

  void _close() {
    if (widget.tooltip.onClose != null) {
      widget.tooltip.onClose!();
    }

    for (final overlay in _overlays) {
      overlay.remove();
    }

    _overlays.clear();
    _isOpen = false;
  }

  _SuperTooltip _superTooltip(Offset targetCenter, Size? size) {
    return _SuperTooltip(
      tooltip: widget.tooltip,
      targetCenter: targetCenter,
      targetSize: size,
      close: _close,
    );
  }

  void _show(BuildContext targetContext, {OverlayState? overlay}) {
    if (_isOpen) {
      _close();
      _isOpen = false;
      return;
    }
    final renderBox = targetContext.findRenderObject() as RenderBox;
    final _overlay = overlay ??= Overlay.of(targetContext);
    OverlayEntry? _backgroundOverlay;
    final overlayRenderBox = _overlay!.context.findRenderObject() as RenderBox?;

    final _targetCenter = renderBox.localToGlobal(
        renderBox.size.center(Offset.zero),
        ancestor: overlayRenderBox);

    // Create the background below the popup including the clipArea.
    final background = widget.tooltip.background;
    if (background != null) {
      _backgroundOverlay = OverlayEntry(
        builder: (context) => SuperTooltipBackground(
          targetCenter: _targetCenter,
          background: background,
          close: _close,
        ),
      );
    }

    final _balloonOverlay = OverlayEntry(
      builder: (context) =>
          _superTooltip(_targetCenter, overlayRenderBox?.size),
    );

    if (_backgroundOverlay != null) {
      _overlays.add(_backgroundOverlay);
    }
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
      child: widget.targetBuilder(
        context,
        ({overlay}) => _show(context, overlay: overlay),
      ),
    );
  }
}

class _SuperTooltip extends StatelessWidget {
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

  EdgeInsets _getBalloonContainerMargin() {
    var top = 0.0;

    if (tooltip.closeButtonPosition?.isOutside ?? false)
      top = tooltip.closeWidget.preferredSize.height + 5;

    final distanceAway = tooltip.pointerDecoration.distanceAway;

    switch (tooltip.tipPosition.direction) {
      case TipDirection.down:
        return EdgeInsets.only(
          top: distanceAway,
        );

      case TipDirection.up:
        return EdgeInsets.only(bottom: distanceAway, top: top);

      case TipDirection.left:
        return EdgeInsets.only(right: distanceAway, top: top);

      case TipDirection.right:
        return EdgeInsets.only(left: distanceAway, top: top);

      default:
        return EdgeInsets.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    var _left = tooltip.tipPosition.left,
        _right = tooltip.tipPosition.right,
        _top = tooltip.tipPosition.top,
        _bottom = tooltip.tipPosition.bottom;
    var _popupDirection = tooltip.tipPosition.direction ?? TipDirection.down;

    /// Handling snap far away feature.
    if (tooltip.tipPosition.snapsVertical) {
      _left = 0.0;
      _right = 0.0;
      if ((targetCenter.dy) > (targetSize?.center(Offset.zero).dy ?? 0)) {
        _popupDirection = TipDirection.up;
        _top = 0.0;
      } else {
        _popupDirection = TipDirection.down;
        _bottom = 0.0;
      }
    }
    // Only one of of them is possible, and vertical has higher priority.
    else if (tooltip.tipPosition.snapsHorizontal) {
      _top = 0.0;
      _bottom = 0.0;
      if (targetCenter.dx < (targetSize?.center(Offset.zero).dx ?? 0)) {
        _popupDirection = TipDirection.right;
        _right = 0.0;
      } else {
        _popupDirection = TipDirection.left;
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
              targetCenter: targetCenter,
              tipConstraints: TipConstraints(
                minWidth: tooltip.constraints?.minWidth,
                maxWidth: tooltip.tipPosition.snapsHorizontal
                    ? null
                    : tooltip.constraints?.maxWidth,
                minHeight: tooltip.constraints?.minHeight,
                maxHeight: tooltip.tipPosition.snapsVertical
                    ? null
                    : tooltip.constraints?.maxHeight,
              ),
              margin: tooltip.margin,
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
                Container(
                    margin: _getBalloonContainerMargin(),
                    clipBehavior: Clip.hardEdge,
                    decoration: ShapeDecoration(
                        color: tooltip.contentBackgroundColor ?? Colors.white,
                        shadows: tooltip.boxShadow,
                        shape: BubbleShape(
                          direction: _popupDirection,
                          targetCenter: targetCenter,
                          borderDecoration: tooltip.borderDecoration,
                          pointerDecoration: tooltip.pointerDecoration,
                          position: TipPosition.fromLTRB(
                            _left,
                            _top,
                            _right,
                            _bottom,
                          ),
                        )),
                    child: Material(
                      type: MaterialType.transparency,
                      child: tooltip.content,
                    )),
                Builder(
                  builder: (context) {
                    final closePosition = tooltip.closeButtonPosition;

                    if (closePosition == null) {
                      return const SizedBox();
                    }

                    double? right;
                    double? top;

                    switch (_popupDirection) {
                      //
                      // LEFT: -------------------------------------
                      case TipDirection.left:
                        right = tooltip.pointerDecoration.distanceAway + 3.0;
                        if (closePosition.isInside) {
                          top = 2.0;
                        } else if (closePosition.isOutside) {
                          top = 0.0;
                        } else
                          throw AssertionError(closePosition);
                        break;

                      // RIGHT/UP: ---------------------------------
                      case TipDirection.right:
                      case TipDirection.up:
                        right = 5.0;
                        if (closePosition.isInside) {
                          top = 2.0;
                        } else if (closePosition.isOutside) {
                          top = 0.0;
                        } else
                          throw AssertionError(closePosition);
                        break;

                      // DOWN: -------------------------------------
                      case TipDirection.down:
                        // If this value gets negative the Shadow gets clipped. The problem occurs is arrowlength + arrowTipDistance
                        // is smaller than _outSideCloseButtonPadding which would mean arrowLength would need to be increased if the button is ouside.
                        right = 2.0;
                        if (closePosition.isInside) {
                          top = tooltip.pointerDecoration.distanceAway + 2.0;
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
                        onTap: close,
                        child: AbsorbPointer(
                          absorbing: true,
                          child: tooltip.closeWidget,
                        ),
                      ),
                    );
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
