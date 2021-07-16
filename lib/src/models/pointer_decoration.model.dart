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
    this.distanceFromCenter = 2,
    this.tipRadius = 2,
  });

  final double baseWidth;
  final double height;
  final double distanceFromCenter;
  final double tipRadius;

  double get distanceAway => height + distanceFromCenter;
}
