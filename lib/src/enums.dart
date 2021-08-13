enum TipDirection {
  up,
  down,
  left,
  right,
}

enum CloseButtonPosition {
  inside,
  outside,
}

extension CloseButtonPositionExtension on CloseButtonPosition {
  bool get isInside => this == CloseButtonPosition.inside;
  bool get isOutside => this == CloseButtonPosition.outside;
}

enum ClipAreaShape {
  oval,
  rectangle,
}

enum SnapAxis {
  /// If [vertical], the bigger free space above or below the target will be
  /// covered completely by the ToolTip
  vertical,

  /// If [horizontal], the bigger free space left or right of the target will be
  /// covered completely by the ToolTip
  horizontal,

  /// If [none], All other dimension or position constraints get overwritten
  none,
}
