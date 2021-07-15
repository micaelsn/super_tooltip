import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BorderDecoration {
  const BorderDecoration({
    ///
    /// The color of the border
    this.color = Colors.black,

    ///
    /// the stroke width of the border
    this.width = 2,

    ///
    /// The corner radius of the border
    this.radius = 10,
  });

  final Color color;
  final double width;
  final double radius;
}
