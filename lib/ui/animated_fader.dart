import 'package:flutter/material.dart';

class MyAnimatedFader extends StatefulWidget {
  final Widget child;
  final bool isVisible;
  const MyAnimatedFader({
    Key? key,
    required this.child,
    required this.isVisible,
  }) : super(key: key);

  @override
  State<MyAnimatedFader> createState() => _MyAnimatedFaderState();
}

class _MyAnimatedFaderState extends State<MyAnimatedFader>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    animationController.value = 1;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVisible) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
    return FadeTransition(opacity: animationController, child: widget.child);
  }
}
