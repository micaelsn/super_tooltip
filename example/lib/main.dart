import 'dart:async';

import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
  }) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.red,
      body: Center(child: TargetWidget()),
    );
  }
}

class TargetWidget extends StatefulWidget {
  const TargetWidget({Key? key}) : super(key: key);

  @override
  _TargetWidgetState createState() => _TargetWidgetState();
}

class _TargetWidgetState extends State<TargetWidget> {
  SuperTooltip? tooltip;

  Future<bool> _willPopCallback() async {
    // If the tooltip is open we don't pop the page on a backbutton press
    // but close the ToolTip
    if (tooltip!.isOpen) {
      tooltip!.close();
      return false;
    }
    return true;
  }

  void onTap() {
    if (tooltip != null && tooltip!.isOpen) {
      tooltip!.close();
      return;
    }

    final renderBox = context.findRenderObject() as RenderBox;
    final overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox?;

    final targetGlobalCenter = renderBox
        .localToGlobal(renderBox.size.center(Offset.zero), ancestor: overlay);

    // We create the tooltip on the first use
    tooltip = SuperTooltip(
      popupDirection: TooltipDirection.up,
      pointerDecoration: const PointerDecoration(
        minDistance: 15,
        baseWidth: 40,
        height: 40,
      ),
      borderDecoration: const BorderDecoration(
        color: Colors.green,
        width: 5,
      ),
      tipPosition: TipPosition.snapTo(SnapToSpace.vertical),
      boxShadow: const [
        BoxShadow(
          color: Colors.black,
          blurRadius: 3,
        )
      ],
      background: TipBackground(
          touchThrough: TouchThrough.rect(
        area: Rect.fromLTWH(
          targetGlobalCenter.dx - 100,
          targetGlobalCenter.dy - 100,
          200.0,
          160.0,
        ),
      )),
      content: const Material(
          child: Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: Text(
          'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, '
          'sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, '
          'sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. ',
          softWrap: true,
        ),
      )),
    );

    tooltip!.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
            width: 100.0,
            height: 100.0,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            )),
      ),
    );
  }
}
