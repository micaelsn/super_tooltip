class PointerDecoration {
  const PointerDecoration({
    ///
    /// The width of the pointer at its base
    this.baseWidth = 20,

    ///
    /// The height of the pointer
    this.height = 20,

    ///
    /// The distance of the tip of the arrow's tip to the center of the target
    this.minDistance = 2,
  });

  final double baseWidth;
  final double height;
  final double minDistance;

  double get distanceAway => height + minDistance;
}
