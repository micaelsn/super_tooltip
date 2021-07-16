class PointerDecoration {
  const PointerDecoration({
    ///
    /// The width of the pointer at its base
    this.baseWidth = 20,

    ///
    /// The height of the pointer
    this.distanceFromCenter = 20,

    ///
    /// The distance of the tip of the arrow's tip to the center of the target
    this.height = 2,
  });

  final double baseWidth;
  final double distanceFromCenter;
  final double height;

  double get distanceAway => distanceFromCenter + height;
}
