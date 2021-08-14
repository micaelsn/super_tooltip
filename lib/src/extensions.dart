// ignore_for_file: avoid_returning_null
import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';

extension CloseButtonPositionExtension on ClosePosition {
  bool get isInside => this == ClosePosition.inside;
  bool get isOutside => this == ClosePosition.outside;
}

extension TipDirectionExt on TipDirection {
  SnapAxis get snap {
    switch (this) {
      case TipDirection.up:
      case TipDirection.down:
        return SnapAxis.vertical;
      case TipDirection.left:
      case TipDirection.right:
        return SnapAxis.horizontal;
    }
  }

  bool get isLeft => this == TipDirection.left;
  bool get isRight => this == TipDirection.right;
  bool get isUp => this == TipDirection.up;
  bool get isDown => this == TipDirection.down;

  double? get top {
    switch (this) {
      case TipDirection.up:
        return 0;
      case TipDirection.down:
      case TipDirection.left:
      case TipDirection.right:
        return null;
    }
  }

  double? get bottom {
    switch (this) {
      case TipDirection.down:
        return 0;
      case TipDirection.up:
      case TipDirection.left:
      case TipDirection.right:
        return null;
    }
  }

  double? get left {
    switch (this) {
      case TipDirection.left:
        return 0;
      case TipDirection.up:
      case TipDirection.down:
      case TipDirection.right:
        return null;
    }
  }

  double? get right {
    switch (this) {
      case TipDirection.right:
        return 0;
      case TipDirection.up:
      case TipDirection.down:
      case TipDirection.left:
        return null;
    }
  }

  EdgeInsets getMargin(SuperTooltip tip) {
    var top = 0.0;
    final distanceAway = tip.arrowDecoration.distanceAway;
    switch (this) {
      case TipDirection.down:
        // if (tip.closeTipObject.position?.isOutside ?? false)
        //   top = tip.closeTipObject.height + 5;
        return EdgeInsets.only(top: distanceAway);

      case TipDirection.up:
        if (tip.closeTipObject.position?.isOutside ?? false)
          top = tip.closeTipObject.height + 5;
        return EdgeInsets.only(bottom: distanceAway, top: top);

      case TipDirection.left:
        return EdgeInsets.only(right: distanceAway, top: top);

      case TipDirection.right:
        return EdgeInsets.only(left: distanceAway, top: top);
    }
  }
}
