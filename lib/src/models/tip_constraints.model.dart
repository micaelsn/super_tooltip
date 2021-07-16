class TipConstraints {
  const TipConstraints({
    this.minHeight,
    this.minWidth,
    this.maxHeight,
    this.maxWidth,
  })  : assert((maxWidth ?? double.infinity) >= (minWidth ?? 0.0)),
        assert((maxHeight ?? double.infinity) >= (minHeight ?? 0.0));

  final double? minHeight;
  final double? minWidth;
  final double? maxHeight;
  final double? maxWidth;
}
