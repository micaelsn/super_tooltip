import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef FadeBuilder = Widget Function(BuildContext, double);

class AnimationWrapper extends StatefulWidget {

  AnimationWrapper({this.builder});

  final FadeBuilder? builder;


  @override
  _AnimationWrapperState createState() => _AnimationWrapperState();
}

class _AnimationWrapperState extends State<AnimationWrapper> {
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          opacity = 1.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder!(context, opacity);
  }
}
