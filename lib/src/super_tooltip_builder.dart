import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:super_tooltip/src/models/tip_constraints.model.dart';

import 'bubble_shape.dart';
import 'enums.dart';
import 'models/models.dart';
import 'models/super_tooltip.model.dart';
import 'pop_up_balloon_layout_delegate.dart';
import 'shape_overlay.dart';

//TODO: Add a controller instead of using the method directly
typedef TargetBuilder = Widget Function(BuildContext, ShowHandler);

/// provide the key if you wish to override the default widget context
typedef ShowHandler = void Function({
  OverlayState? overlay,
  GlobalKey? key,
});

var _isShowing = false;

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

  void _remove() async {
    if (widget.tooltip.onClose != null) {
      widget.tooltip.onClose!();
    }

    for (final overlay in _overlays) {
      overlay.remove();
    }

    _overlays.clear();
    _isShowing = false;
  }

  _SuperTooltip _superTooltip(
    Offset targetCenter,
    Size? size,
  ) {
    return _SuperTooltip(
      tooltip: widget.tooltip,
      targetCenter: targetCenter,
      targetSize: size,
      close: _remove,
    );
  }

  void _show(
    BuildContext targetContext, {
    OverlayState? overlay,
    GlobalKey? key,
  }) async {
    if (key != null)
      assert(key.currentWidget != null, 'The key must be assigned to a widget');
    if (_isShowing) {
      _remove();
      _isShowing = false;
      return;
    }
    var _context = targetContext;
    if (key != null && key.currentContext != null)
      _context = key.currentContext!;

    final renderBox = _context.findRenderObject() as RenderBox;
    final _overlay = overlay ??= Overlay.of(_context);
    final overlayRenderBox = _overlay!.context.findRenderObject() as RenderBox?;

    final _targetCenter = renderBox.localToGlobal(
        renderBox.size.center(Offset.zero),
        ancestor: overlayRenderBox);

    final _balloonOverlay = OverlayEntry(
      builder: (context) => _superTooltip(
        _targetCenter,
        overlayRenderBox?.size,
      ),
    );

    _overlays.add(_balloonOverlay);

    _overlay.insertAll(_overlays);
    _isShowing = true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // If the tooltip is open we don't pop the page on a backbutton press
        // but close the ToolTip
        if (_isShowing) {
          _remove();
          return false;
        }
        return true;
      },
      child: widget.targetBuilder(
        context,
        ({overlay, key}) => _show(context, overlay: overlay, key: key),
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
  late double opacity;
  final _animatedDuration = const Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    opacity = 0;

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _updateVisibility(1);
    });
  }

  @override
  void dispose() {
    // TODO: test dispose method and removing tooltip
    _close(updateVisibility: false);
    super.dispose();
  }

  Future<void> _updateVisibility(double newOpacity) async {
    setState(() {
      opacity = newOpacity;
    });
    await Future.delayed(_animatedDuration);
  }

  EdgeInsets _getBalloonContainerMargin(TipDirection tipDirection) {
    var top = 0.0;

    if (widget.tooltip.closeTipObject.position?.isOutside ?? false)
      top = widget.tooltip.closeTipObject.height + 5;

    final distanceAway = widget.tooltip.arrowDecoration.distanceAway;

    switch (tipDirection) {
      case TipDirection.down:
        return EdgeInsets.only(top: distanceAway);

      case TipDirection.up:
        return EdgeInsets.only(bottom: distanceAway, top: top);

      case TipDirection.left:
        return EdgeInsets.only(right: distanceAway, top: top);

      case TipDirection.right:
        return EdgeInsets.only(left: distanceAway, top: top);

      default:
        throw AssertionError(
            'Unsupported TipDirection ${widget.tooltip.tipPosition.direction}');
      // return EdgeInsets.zero;
    }
  }

  void _close({bool updateVisibility = true}) async {
    if (updateVisibility) await _updateVisibility(0);
    widget.close();
  }

  @override
  Widget build(BuildContext context) {
    var _left = widget.tooltip.tipPosition.left,
        _right = widget.tooltip.tipPosition.right,
        _top = widget.tooltip.tipPosition.top,
        _bottom = widget.tooltip.tipPosition.bottom;
    var _popupDirection = widget.tooltip.tipPosition.direction;

    /// Handling snap far away feature.
    if (widget.tooltip.tipPosition.snapsVertical) {
      _left = 0.0;
      _right = 0.0;
      if ((widget.targetCenter.dy) >
          (widget.targetSize?.center(Offset.zero).dy ?? 0)) {
        _popupDirection = TipDirection.up;
        _top = 0.0;
      } else {
        _popupDirection = TipDirection.down;
        _bottom = 0.0;
      }
    }
    // Only one of of them is possible, and vertical has higher priority.
    else if (widget.tooltip.tipPosition.snapsHorizontal) {
      _top = 0.0;
      _bottom = 0.0;
      if (widget.targetCenter.dx <
          (widget.targetSize?.center(Offset.zero).dx ?? 0)) {
        _popupDirection = TipDirection.right;
        _right = 0.0;
      } else {
        _popupDirection = TipDirection.left;
        _left = 0.0;
      }
    }

    final content = Container(
      margin: _getBalloonContainerMargin(_popupDirection),
      decoration: ShapeDecoration(
        color: widget.tooltip.contentBackgroundColor,
        shadows: widget.tooltip.boxShadow ??
            kElevationToShadow[widget.tooltip.elevation],
        shape: BubbleShape(
          backgroundColor: widget.tooltip.contentBackgroundColor,
          direction: _popupDirection,
          targetCenter: widget.targetCenter,
          borderDecoration: widget.tooltip.borderDecoration,
          pointerDecoration: widget.tooltip.arrowDecoration,
          position: TipPosition.fromLTRB(
            _left,
            _top,
            _right,
            _bottom,
          ),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: (widget.tooltip.closeTipObject.position?.isInside ?? false)
              ? EdgeInsets.only(
                  right: widget.tooltip.closeTipObject.width -
                      _getBalloonContainerMargin(_popupDirection).right -
                      8)
              : EdgeInsets.zero,
          child: widget.tooltip.content,
        ),
      ),
    );

    return AnimatedOpacity(
      opacity: opacity,
      duration: widget.tooltip.animationDuration,
      curve: Curves.easeInOut,
      child: Center(
        child: Stack(
          children: [
            if (widget.tooltip.background != null)
              Positioned.fill(
                child: SuperTooltipBackground(
                  background: widget.tooltip.background!,
                  close: _close,
                  targetCenter: widget.targetCenter,
                ),
              ),
            Positioned.fill(
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
                  margin: widget.tooltip.margin,
                  position: TipPosition.fromLTRB(
                    _left,
                    _top,
                    _right,
                    _bottom,
                  ),
                ),
                child: Stack(
                  fit: StackFit.passthrough,
                  clipBehavior: Clip.none,
                  children: [
                    if (widget.tooltip.tipPosition.hasSnaps)
                      Positioned.fill(child: content)
                    else
                      content,
                    Builder(
                      builder: (context) {
                        final closePosition =
                            widget.tooltip.closeTipObject.position;

                        if (closePosition == null)
                          return const SizedBox(height: 0);

                        double? right;
                        double? top;

                        switch (_popupDirection) {
                          //
                          // LEFT: -------------------------------------
                          case TipDirection.left:
                            right =
                                widget.tooltip.arrowDecoration.distanceAway +
                                    3.0;
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
                              top =
                                  widget.tooltip.arrowDecoration.distanceAway +
                                      2.0;
                            } else if (closePosition.isOutside) {
                              top = -widget.tooltip.closeTipObject.height +
                                  widget.tooltip.arrowDecoration.distanceAway -
                                  2;
                            } else
                              throw AssertionError(closePosition);
                            break;
                        }

                        return Positioned(
                          right: right,
                          top: top,
                          child: GestureDetector(
                            onTap: _close,
                            child: AbsorbPointer(
                              absorbing: true,
                              child: SizedBox(
                                height: widget.tooltip.closeTipObject.height,
                                width: widget.tooltip.closeTipObject.width,
                                child: widget.tooltip.closeTipObject.child ??
                                    const PreferredSize(
                                      preferredSize: Size.fromHeight(35),
                                      child: Icon(Icons.close),
                                    ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
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

    final touchThrough = background.touchThrough;
    final position = touchThrough?.position != null
        ? touchThrough!.position!(targetCenter)
        : targetCenter;

    final shapeOverlay = ShapeOverlay(
      touchThrough?.isCustom ?? false
          ? touchThrough!.area
          : Rect.fromCenter(
              center: Offset(
                position.dx,
                position.dy,
              ),
              width: (touchThrough?.area.width ?? 0),
              height: (touchThrough?.area.height ?? 0),
            ),
      touchThrough?.shape ?? ClipAreaShape.rectangle,
      touchThrough?.borderRadius ?? 0,
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
    return backgroundContent;
  }
}
