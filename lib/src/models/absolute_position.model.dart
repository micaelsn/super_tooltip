import 'package:super_tooltip/super_tooltip.dart';

class TipPosition {
  const TipPosition._(
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.snapTo,
  );

  factory TipPosition({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return TipPosition._(
      left,
      top,
      right,
      bottom,
      SnapToSpace.none,
    );
  }

  factory TipPosition.fromLTRB(
    double? left,
    double? top,
    double? right,
    double? bottom,
  ) {
    return TipPosition._(
      left,
      top,
      right,
      bottom,
      SnapToSpace.none,
    );
  }

  factory TipPosition.snapTo(SnapToSpace position) {
    return TipPosition._(
      null,
      null,
      null,
      null,
      position,
    );
  }

  final double? top;
  final double? left;
  final double? bottom;
  final double? right;
  final SnapToSpace snapTo;

  ///
  /// If [snapsHorizontal] == true the bigger free space left or right of the target will be
  /// covered completely by the ToolTip. All other dimension or position constraints get overwritten
  bool get snapsHorizontal => snapTo == SnapToSpace.horizontal;

  ///
  /// If [snapsVertical] == true the bigger free space above or below the target will be
  /// covered completely by the ToolTip. All other dimension or position constraints get overwritten
  bool get snapsVertical => snapTo == SnapToSpace.vertical;
}
