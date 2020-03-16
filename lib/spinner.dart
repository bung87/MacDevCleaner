import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';


class Spinner extends StatefulWidget {
  double diameter;
  Color color;
  int delay;
  Spinner(this.diameter, this.color,this.delay );
  _SpinnerState createState() => _SpinnerState(this.diameter, this.color, this.delay);
}

class _SpinnerState extends State<Spinner> with TickerProviderStateMixin {
  final double diameter;
  final Color color;
  final int delay;
  _SpinnerState(this.diameter, this.color,this.delay);
  AnimationController _controller;
  Animation<double> _animation;

  initState() {
    super.initState();
    _controller = AnimationController(
        lowerBound: 0.9,
        duration: const Duration(milliseconds: 1000),
        vsync: this,
        upperBound: 1);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.bounceIn);

    Future.delayed( Duration(milliseconds: this.delay), () {
      _controller.repeat(reverse: true);
    });
    
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Container(
        // color: Colors.white,
        child: ScaleTransition(
            scale: _animation,
            alignment: Alignment.center,
            child: new Container(
              width: this.diameter ,
              height: this.diameter ,
              decoration: new BoxDecoration(
                // 0xddff9800
                //Colors.lightBlue
                color: this.color,
                shape: BoxShape.circle,
              ),
            )));
  }
}
