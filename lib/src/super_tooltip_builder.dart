import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:super_tooltip/src/close_object.dart';
import 'package:super_tooltip/src/models/tip_constraints.model.dart';
import 'package:super_tooltip/src/super_tooltip_background.dart';

import 'bubble_shape.dart';
import 'extensions.dart';
import 'models/models.dart';
import 'models/super_tooltip.model.dart';
import 'pop_up_balloon_layout_delegate.dart';
import 'public_enums.dart';

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

  void _close({bool updateVisibility = true}) async {
    if (updateVisibility) await _updateVisibility(0);
    widget.close();
  }

  @override
  Widget build(BuildContext context) {
    var position = widget.tooltip.tipContent.position;
    var _left = position.left,
        _right = position.right,
        _top = position.top,
        _bottom = position.bottom;
    var _popupDirection = position.direction;
    var _contentRight = 0.0, _contentTop = 0.0;
    var _wrapInSafeArea = false;

    /// Handling snap far away feature.
    if (position.snapsVertical) {
      _left = 0.0;
      _right = 0.0;
      _contentRight = widget.tooltip.closeTipObject.width -
          _popupDirection.getMargin(widget.tooltip).right -
          8;
      if (position.hasPreference) {
        if (position.direction.isUp) {
          _top = 0.0;
          _popupDirection = TipDirection.up;
        } else {
          _bottom = 0.0;
          _popupDirection = TipDirection.down;
        }
      } else
      // check if top position is greater than bottom
      if ((widget.targetCenter.dy) >
          (widget.targetSize?.center(Offset.zero).dy ?? 0)) {
        _popupDirection = TipDirection.up;
        _top = 0.0;
      } else {
        _popupDirection = TipDirection.down;
        _bottom = 0.0;
      }
    } else if (position.snapsHorizontal) {
      _top = 0.0;
      _bottom = 0.0;
      _wrapInSafeArea = true;
      if (position.hasPreference) {
        if (position.direction.isRight) {
          _right = 0.0;
          _popupDirection = TipDirection.right;
        } else {
          _left = 0.0;
          _popupDirection = TipDirection.left;
        }
      } else {
        if (widget.tooltip.closeTipObject.position?.isInside ?? false) {
          _contentTop = widget.tooltip.closeTipObject.height;
        }

        // check if right position is greater than left
        if (widget.targetCenter.dx <
            (widget.targetSize?.center(Offset.zero).dx ?? 0)) {
          _popupDirection = TipDirection.right;

          _right = 0.0;
        } else {
          _popupDirection = TipDirection.left;
          _left = 0.0;
        }
      }
    }

    final content = Container(
      margin: _popupDirection.getMargin(widget.tooltip),
      decoration: ShapeDecoration(
        color: widget.tooltip.tipContent.backgroundColor,
        shadows: widget.tooltip.boxShadow ??
            kElevationToShadow[widget.tooltip.elevation],
        shape: BubbleShape(
          backgroundColor: widget.tooltip.tipContent.backgroundColor,
          direction: _popupDirection,
          targetCenter: widget.targetCenter,
          borderDecoration: widget.tooltip.borderDecoration,
          arrowDecoration: widget.tooltip.arrowDecoration,
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
              ? EdgeInsets.fromLTRB(
                  0,
                  _contentTop,
                  _contentRight,
                  0,
                )
              : EdgeInsets.zero,
          child: _wrapInSafeArea
              ? SafeArea(
                  child: widget.tooltip.tipContent.child,
                )
              : widget.tooltip.tipContent.child,
        ),
      ),
    );

    // TODO: expose the animation to the public
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
                    maxWidth: position.snapsHorizontal
                        ? null
                        : widget.tooltip.constraints?.maxWidth,
                    minHeight: widget.tooltip.constraints?.minHeight,
                    maxHeight: position.snapsVertical
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
                    if (position.hasSnaps)
                      Positioned.fill(child: content)
                    else
                      content,
                    CloseObject(
                      widget.tooltip,
                      direction: _popupDirection,
                      close: _close,
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
