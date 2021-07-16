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
  @override
  Widget build(BuildContext context) {
    return SuperTooltipBuilder(
      key: const Key('tooltip'),
      tooltip: SuperTooltip(
        popupDirection: TooltipDirection.up,
        pointerDecoration: const PointerDecoration(
          minDistance: 15,
          baseWidth: 100,
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
          area: const Rect.fromLTWH(
            100,
            100,
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
      ),
      targetBuilder: (context, show) {
        return GestureDetector(
          onTap: () {
            show(context);
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
