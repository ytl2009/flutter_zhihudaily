import 'package:flutter/material.dart';

class Dot extends StatefulWidget {
  int _count = 0;

  Dot(int count) {
    this._count = count;
  }

  @override
  State<StatefulWidget> createState() {
    return new DotState(this._count);
  }
}

class DotState extends State<Dot> {
  int curIndex;
  int count;
  List<Widget> _dots = [];

  DotState(int count) {
    this.count = count;
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * 0.6,
      color: Colors.transparent,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _roundDot,
          _roundDot,
          _roundDot,
          _roundDot,
          _roundDot
        ],
      ),
    );
  }

  var _roundDot = new Container(
    width: 10.0,
    height: 10.0,
    decoration: new BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xFFECECEC),
      border: new Border.all(
        color: Colors.indigoAccent,
        width: 2.0,
      ),
    ),
  );

  _getRoundDots(int count) {
    if (count > 0) {
      for (int i = 0; i < count; i++) {
        _dots.add(_roundDot);
      }
    }
    return _dots;
  }
}
