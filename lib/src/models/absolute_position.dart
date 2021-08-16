import 'package:super_tooltip/super_tooltip.dart';

class AbsolutePosition {
  AbsolutePosition({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  }) {
    _direction = null;
  }

  factory AbsolutePosition.fromDirection(TipDirection direction) {
    final absolute = AbsolutePosition(
      bottom: null,
      left: null,
      right: null,
      top: null,
    );
    _direction = direction;
    return absolute;
  }

  static TipDirection? _direction;

  final double? left;
  final double? top;
  final double? right;
  final double? bottom;

  bool get hasBottomLeftRadius => !(left == 0 && bottom == 0);
  bool get hasBottomRightRadius => !(right == 0 && bottom == 0);
  bool get hasTopLeftRadius => !(left == 0 && top == 0);
  bool get hasTopRightRadius => !(right == 0 && top == 0);

  bool get isRightSide => right == 0;
  bool get isLeftSide => left == 0;
  bool get isTopSide => top == 0;
  bool get isBottomSide => bottom == 0;

  /// If [snapsVertical] == true the bigger free space above or below the target will be
  /// covered completely by the ToolTip.
  bool get snapsVertical => left == 0 && right == 0;

  /// If [snapsHorizontal] == true the bigger free space left or right of the target will be
  /// covered completely by the ToolTip.
  bool get snapsHorizontal => top == 0 && bottom == 0;

  bool get snaps => snapsVertical || snapsHorizontal;

  TipDirection get direction {
    if (_direction != null) return _direction!;
    if (left == 0 && right == 0) {
      if (top == 0) return TipDirection.up;
      if (bottom == 0) return TipDirection.down;
    } else if (top == 0 && bottom == 0) {
      if (left == 0) return TipDirection.left;
      if (right == 0) return TipDirection.right;
    }
    return TipDirection.down;
  }
}
