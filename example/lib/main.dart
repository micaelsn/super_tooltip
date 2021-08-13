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
        arrowDecoration: const ArrowDecoration(
          distanceFromCenter: 16,
          baseWidth: 60,
          height: 30,
        ),
        margin: 16,
        closeButtonPosition: CloseButtonPosition.inside,
        borderDecoration: const BorderDecoration(
          color: Colors.black,
          width: 1,
        ),
        // tipPosition: TipPosition.side(direction)
        background: TipBackground(
          absorbPointerEvents: false,
          touchThrough: TouchThrough.rect(
            area: const SizedBox(
              height: 150,
              width: 200,
            ),
            position: (center) {
              return center;
            },
          ),
        ),
        contentBackgroundColor: Colors.pink,
        content: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. ',
            softWrap: true,
          ),
        ),
        closeWidget: const PreferredSize(
          preferredSize: Size(30, 30),
          child: SafeArea(
            child: Center(
              child: Icon(Icons.delete),
            ),
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
