import 'package:super_tooltip/super_tooltip.dart';

class TipPosition {
  const TipPosition._({
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.snapTo = SnapToSpace.none,
    this.direction,
  });

  factory TipPosition({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return TipPosition._(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }

  factory TipPosition.fromLTRB(
    double? left,
    double? top,
    double? right,
    double? bottom,
  ) {
    return TipPosition._(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }

  factory TipPosition.snapTo(SnapToSpace position) {
    return TipPosition._(
      snapTo: position,
    );
  }

  static TipPosition get leftSide {
    return const TipPosition._(
      direction: TooltipDirection.left,
    );
  }

  static TipPosition get rightSide {
    return const TipPosition._(
      direction: TooltipDirection.right,
    );
  }

  static TipPosition get topSide {
    return const TipPosition._(
      direction: TooltipDirection.up,
    );
  }

  static TipPosition get bottomSide {
    return const TipPosition._(
      direction: TooltipDirection.down,
    );
  }

  final double? top;
  final double? left;
  final double? bottom;
  final double? right;
  final SnapToSpace snapTo;

  ///
  /// The direcion in which the tooltip should open
  final TooltipDirection? direction;

  ///
  /// If [snapsHorizontal] == true the bigger free space left or right of the target will be
  /// covered completely by the ToolTip.
  bool get snapsHorizontal => snapTo == SnapToSpace.horizontal;

  ///
  /// If [snapsVertical] == true the bigger free space above or below the target will be
  /// covered completely by the ToolTip.
  bool get snapsVertical => snapTo == SnapToSpace.vertical;
}
