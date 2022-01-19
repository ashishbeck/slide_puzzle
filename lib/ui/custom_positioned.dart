import 'package:flutter/material.dart';

class MyPositioned extends StatelessWidget {
  final bool isWhite;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double top;
  final double left;
  const MyPositioned({
    Key? key,
    required this.isWhite,
    required this.child,
    required this.duration,
    required this.curve,
    required this.top,
    required this.left,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isWhite) {
      return Positioned(
        top: top,
        left: left,
        child: child,
      );
    }
    return AnimatedPositioned(
      child: child,
      duration: duration,
      curve: curve,
      top: top,
      left: left,
    );
  }
}
