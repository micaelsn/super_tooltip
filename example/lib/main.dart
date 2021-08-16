import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';

void main() => runApp(MyApp());

// TODO: play around with the close object. Allow position (left, right, up, down) to be set.

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
    return Scaffold(
      backgroundColor: Colors.red,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 100.0,
            height: 100.0,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
          ),
          const Spacer(),
          const Center(child: TargetWidget()),
          const Spacer(),
        ],
      ),
    );
  }
}

class TargetWidget extends StatefulWidget {
  const TargetWidget({Key? key}) : super(key: key);

  @override
  _TargetWidgetState createState() => _TargetWidgetState();
}

class _TargetWidgetState extends State<TargetWidget> {
  @override
  Widget build(BuildContext context) {
    return SuperTooltipBuilder(
      key: const Key('tooltip'),
      tooltip: SuperTooltip(
        elevation: 8,
        // closeTipObject: CloseTipObject.outside(
        closeTipObject: CloseTipObject.inside(
          child: Container(
            color: Colors.white,
            child: const Icon(Icons.remove),
          ),
          margin: const EdgeInsets.only(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
          ),
          height: 100,
          width: 100,
        ),
        arrowDecoration: const ArrowDecoration(
          distanceFromCenter: 16,
          baseWidth: 40,
          height: 30,
        ),
        borderDecoration: const BorderDecoration(
          color: Colors.black,
          width: 1,
          radius: 8,
        ),
        background: TipBackground(
          absorbPointerEvents: false,
          touchThrough: TouchThrough.square(),
        ),
        //TODO: fix the following items
/*
    left: snap & non-snap
    bottom: snap (non-snap works)
    top: non-snap (snap works)
*/
        tipContent: TipContent.blur(
          // position: TipPosition.side(TipDirection.up),
          position: TipPosition.snapSide(TipDirection.up),
          // position: TipPosition.snap(SnapAxis.vertical),

          // position: TipPosition.fromLTRB(30, 30, 30, 30),
          backgroundColor: Colors.pink.withOpacity(.3),
          child: const Text(
            's e d  d i a m  v o l u p t u a . A t  v e r o  e o s  e t  a c c u s a m  e t  j u s t o  d u o  d o l o r e s  e t  e a  r e b u m '
            's e d  d i a m  v o l u p t u a . A t  v e r o  e o s  e t  a c c u s a m  e t  j u s t o  d u o  d o l o r e s  e t  e a  r e b u m ',
            softWrap: true,
          ),
        ),
      ),
      targetBuilder: (context, show) {
        return GestureDetector(
          onTap: () {
            show();
          },
          child: Container(
            width: 100.0,
            height: 100.0,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
          ),
        );
      },
    );
  }
}
