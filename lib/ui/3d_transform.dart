import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:slide_puzzle/code/constants.dart';

class MyTransform extends StatefulWidget {
  final Widget child;
  const MyTransform({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _MyTransformState createState() => _MyTransformState();
}

class _MyTransformState extends State<MyTransform>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation animation;
  double x = -0.46000000000000024;
  double y = -0.4000000000000002;

  //initial state = (-0.46000000000000024, -0.4000000000000002)

  _listener() {
    // print(animation.value);
    setState(() {
      // x = (1 - animation.value) * -0.10999999999999999;
      // y = (1 - animation.value) * -0.13999999999999999;
      // x = (1 - animation.value) * -0.029849349708536;
      // y = (1 - animation.value) * -0.24324220468129937;
      x = (1 - animation.value) * -0.060000000000000005;
      y = (1 - animation.value) * -0.8300000000000005;
    });
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: defaultEntryTime * 2));
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    animationController.addListener(_listener);
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.removeListener(_listener);
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Transform.scale(
          scale: (animation.value * 0.2) + 0.8,
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2,
                  0.0003) // col = 2, row = 3 & 0.003 = depth perception in the Z direction
              ..rotateX(x)
              ..rotateY(
                  y), // (Both are equal because both are 4D identity matrix)
            // transform: Matrix4(
            //   1, 0, 0, 0,
            //   0, 1, 0, 0,
            //   0, 0, 1, 0.003,
            //   0, 0, 0, 1,
            // )..rotateX(x),
            alignment: FractionalOffset.center,
            child: GestureDetector(
              onPanUpdate: (details) {
                if (kDebugMode) {
                  setState(() {
                    x = x + details.delta.dy / 100;
                    y = y + details.delta.dx / 100;
                  });
                  print("($x, $y)");
                }
              },
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
