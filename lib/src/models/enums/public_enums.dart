enum TipDirection {
  up,
  down,
  left,
  right,
}

enum ClosePosition {
  inside,
  outside,
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
