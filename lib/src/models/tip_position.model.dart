import 'package:flutter/material.dart';
import 'package:super_tooltip/src/extensions.dart';
import 'package:super_tooltip/src/models/absolute_position.dart';
import 'package:super_tooltip/super_tooltip.dart';

class TipPosition {
  // ignore: unused_element
  const TipPosition._({
    this.hasPreference = false,
    this.snapTo = SnapAxis.none,
    this.direction = TipDirection.down,
  });

  const TipPosition.snap(this.snapTo)
      : hasPreference = false,
        direction = TipDirection.down;

  TipPosition.snapSide(this.direction)
      : hasPreference = true,
        snapTo = direction.snap;

  const TipPosition.side(this.direction)
      : hasPreference = false,
        snapTo = SnapAxis.none;

  final SnapAxis snapTo;
  final bool hasPreference;

  /// The direcion in which the tooltip should open
  final TipDirection direction;

  /// If [snapsHorizontal] == true the bigger free space left or right of the target will be
  /// covered completely by the ToolTip.
  bool get snapsHorizontal => snapTo == SnapAxis.horizontal;

  /// If [snapsVertical] == true the bigger free space above or below the target will be
  /// covered completely by the ToolTip.
  bool get snapsVertical => snapTo == SnapAxis.vertical;
  bool get hasSnaps => snapsHorizontal || snapsVertical;

  double? left(Offset center, Size? size) {
    if (hasSnaps) {
      if (snapsVertical) {
        return 0;
      } else {
        if (hasPreference) {
          if (direction.isLeft) return 0;
        } else if (center.dx >= (size?.center(Offset.zero).dx ?? 0)) return 0;
      }
    }
  }

  double? right(Offset center, Size? size) {
    if (hasSnaps) {
      if (snapsVertical) {
        return 0;
      } else {
        if (hasPreference) {
          if (direction.isRight) return 0;
        } else if (center.dx < (size?.center(Offset.zero).dx ?? 0)) return 0;
      }
    }
  }

  double? top(Offset center, Size? size) {
    if (hasSnaps) {
      if (snapsHorizontal) {
        return 0;
      } else {
        if (hasPreference) {
          if (direction.isUp) return 0;
        } else if (center.dy > (size?.center(Offset.zero).dy ?? 0)) return 0;
      }
    }
  }

  double? bottom(Offset center, Size? size) {
    if (hasSnaps) {
      if (snapsHorizontal) {
        return 0;
      } else {
        if (hasPreference) {
          if (direction.isDown) return 0;
        } else if (center.dy < (size?.center(Offset.zero).dy ?? 0)) return 0;
      }
    }
  }

  AbsolutePosition getPosition(Offset center, Size? size) {
    final absolute = AbsolutePosition(
      bottom: bottom(center, size),
      left: left(center, size),
      right: right(center, size),
      top: top(center, size),
    );

    if (absolute.snaps) return absolute;
    return AbsolutePosition.fromDirection(direction);
  }
}
