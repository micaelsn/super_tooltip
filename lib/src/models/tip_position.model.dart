import 'package:super_tooltip/super_tooltip.dart';

class TipPosition {
  const TipPosition._({
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.snapTo = SnapAxis.none,
    this.direction = TipDirection.down,
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

  factory TipPosition.snap(SnapAxis position) {
    return TipPosition._(
      snapTo: position,
    );
  }

  factory TipPosition.side(TipDirection direction) {
    return TipPosition._(direction: direction);
  }

  final double? top;
  final double? left;
  final double? bottom;
  final double? right;
  final SnapAxis snapTo;

  /// The direcion in which the tooltip should open
  final TipDirection direction;

  bool get isRightSide => right == 0;
  bool get isLeftSide => left == 0;
  bool get isTopSide => top == 0;
  bool get isBottomSide => bottom == 0;

  /// If [snapsHorizontal] == true the bigger free space left or right of the target will be
  /// covered completely by the ToolTip.
  bool get snapsHorizontal =>
      snapTo == SnapAxis.horizontal || (left == 0 && right == 0);

  /// If [snapsVertical] == true the bigger free space above or below the target will be
  /// covered completely by the ToolTip.
  bool get snapsVertical =>
      snapTo == SnapAxis.vertical || (top == 0 && bottom == 0);
  bool get hasSnaps => snapsHorizontal || snapsVertical;

  bool get hasBottomLeftRadius => left == 0 || bottom == 0;
  bool get hasBottomRightRadius => right == 0 || bottom == 0;
  bool get hasTopLeftRadius => left == 0 || top == 0;
  bool get hasTopRightRadius => right == 0 || top == 0;
}
