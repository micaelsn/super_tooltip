import 'package:super_tooltip/src/extensions.dart';
import 'package:super_tooltip/super_tooltip.dart';

class TipPosition {
  // ignore: unused_element
  const TipPosition._({
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.hasPreference = false,
    this.snapTo = SnapAxis.none,
    this.direction = TipDirection.down,
  });

  const TipPosition({
    this.left,
    this.top,
    this.right,
    this.bottom,
  })  : snapTo = SnapAxis.none,
        hasPreference = false,
        direction = TipDirection.down;

  const TipPosition.fromLTRB(
    this.left,
    this.top,
    this.right,
    this.bottom,
  )   : snapTo = SnapAxis.none,
        hasPreference = false,
        direction = TipDirection.down;

  const TipPosition.snap(this.snapTo)
      : bottom = null,
        top = null,
        left = null,
        right = null,
        hasPreference = false,
        direction = TipDirection.down;

  TipPosition.snapSide(this.direction)
      : bottom = null,
        top = null,
        left = null,
        right = null,
        hasPreference = true,
        snapTo = direction.snap;

  const TipPosition.side(this.direction)
      : bottom = null,
        top = null,
        left = null,
        right = null,
        hasPreference = false,
        snapTo = SnapAxis.none;

  final double? top;
  final double? left;
  final double? bottom;
  final double? right;
  final SnapAxis snapTo;
  final bool hasPreference;

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
