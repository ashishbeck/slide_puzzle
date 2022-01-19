import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Widget child;
  final Function() onPressed;
  final bool expanded;
  const MyButton(
      {Key? key,
      required this.child,
      required this.onPressed,
      required this.expanded})
      : super(key: key);

  Widget button() {
    return Container(
      width: 92,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: expanded ? 8 : 24),
      child: ElevatedButton(
        child: child,
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (expanded) {
      return Expanded(
        child: button(),
      );
    }
    return button();
  }
}
