import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dock Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Dock demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);


  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _dockItemDefaultSize = 40.0;
  final _dockItemDefaultSizeWithSpacing = 100.0;
  var _offset = 0.0;
  var _currentIndex = -1;

  List<int> values = [for (var i = 0; i < 6; i += 1) i];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _getBody(),
    );
  }

  Widget _getBody() {
    return Stack(
      children: [Positioned(bottom: 40, right: 0, left: 0, child: _getDock())],
    );
  }

  double _getOffset() {
    return _offset / _dockItemDefaultSizeWithSpacing;
  }

  Widget _getDock() {
    return Center(
      child: MouseRegion(
        onHover: (event) {
          setState(() {
            _offset = event.localPosition.dx;
            _currentIndex = (_getOffset()).toInt();
          });
        },
        onExit: (event) {
          setState(() {
            _offset = 0;
            _currentIndex = -1;
          });
        },
        child: Container(
          color: Colors.black38,
          width: _dockItemDefaultSizeWithSpacing * values.length,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _getChildren(),
          ),
        ),
      ),
    );
  }

  double _getVariation(double x, double x0, double radius) {
    if (_offset == 0) return 0;
    var z = (x - x0) * (x - x0) - radius;
    if (z > 0) return 0;
    return sqrt(-z / radius);
  }

  List<Widget> _getChildren() {
    List<Widget> items = [];
    for (var i = 0; i < values.length; i++) {
      items.add(Listener(
          onPointerDown: (event) {
            _onPointerDown(event, _currentIndex);
          },
          child: _generateItem(i)));
    }

    return items;
  }

  Future<void> _onPointerDown(PointerDownEvent event, int currentIndex) async {
    List<PopupMenuEntry<int>> menuItems;

    menuItems = [
      PopupMenuItem(child: Text('apply +1'), value: 1),
      PopupMenuItem(child: Text('apply -1'), value: 2),
      PopupMenuItem(child: Text('set to 0'), value: 3),
    ];

    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons == kSecondaryMouseButton) {
      final overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox;
      final menuItem = await showMenu<int>(
          context: context,
          items: menuItems,
          position: RelativeRect.fromSize(
              event.position & Size(48.0, 48.0), overlay.size));

      switch (menuItem) {
        case 0:
          // open;
          break;
        case 1:
          // show all;
          values[currentIndex] = values[currentIndex] + 1;
          break;
        case 2:
          // hide all;
          values[currentIndex] = values[currentIndex] - 1;
          break;
        case 3:
          // close all;
          values[currentIndex] = 0;
          break;
        default:
      }
      setState(() {});
    }
  }

  Widget _generateItem(int index) {
    double dx = _getVariation(index + 0.5, _getOffset(), 3);
    return Container(
      width: _dockItemDefaultSizeWithSpacing,
      margin: EdgeInsets.only(bottom: dx * 20),
      child: Center(
        child: Card(
          color: index == _currentIndex ? Colors.blue : Colors.white,
          child: Container(
            height: _dockItemDefaultSize,
            width: _dockItemDefaultSize,
            child: Center(
              child: Text(values[index].toString()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _generateItemWithRotate(int index) {
    double dx = _getVariation(index + 0.5, _getOffset(), 1);
    print(dx);
    return Container(
      width: _dockItemDefaultSizeWithSpacing,
      child: Center(
        child: Transform.rotate(
          angle: dx * pi / 2,
          child: Card(
            color: index == _currentIndex ? Colors.blue : Colors.white,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Transform.rotate(
                      angle: -pi / 2, child: Center(child: Text("Click!"))),
                ),
                Opacity(
                  opacity: 1 - dx,
                  child: Container(
                    color: Colors.white,
                    height: _dockItemDefaultSize,
                    width: _dockItemDefaultSize,
                    child: Center(
                      child: Text(values[index].toString()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _generateItemColored(int index) {
    double dx =
        _getVariation(index + 0.5, _getOffset(), values.length.toDouble());

    return Container(
      width: _dockItemDefaultSizeWithSpacing,
      child: Center(
        child: Card(
          color: Color.lerp(Colors.deepPurple, Colors.blue, dx),
          child: Container(
            height: _dockItemDefaultSize,
            width: _dockItemDefaultSize,
            child: Center(
              child: Text(
                values[index].toString(),
                style: TextStyle(
                    color: Color.lerp(Colors.deepPurple, Colors.white, dx)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _generateItemWithFlip(int index) {
    double dx = _getVariation(index + 0.5, _getOffset(), 1);
    print(dx);
    return Container(
      width: _dockItemDefaultSizeWithSpacing,
      child: Center(
          child: Transform(
        alignment: FractionalOffset.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateX(pi * dx),
        child: Card(
          color: index == _currentIndex ? Colors.blue : Colors.white,
          child: Stack(
            children: [
              Positioned.fill(
                child: Transform.rotate(
                    angle: pi, child: Center(child: Text("😎"))),
              ),
              Opacity(
                opacity: 1 - dx,
                child: Container(
                  color: Colors.white,
                  height: _dockItemDefaultSize,
                  width: _dockItemDefaultSize,
                  child: Center(
                    child: Text(values[index].toString()),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
