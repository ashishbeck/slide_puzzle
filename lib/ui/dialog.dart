import 'package:flutter/material.dart';

import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/ui/bordered_container.dart';

class MyDialog extends StatefulWidget {
  final Widget child;
  final double? height;
  final double? width;
  const MyDialog({
    Key? key,
    required this.child,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: defaultTime));
    animation = CurvedAnimation(parent: controller, curve: Curves.easeOutQuart);
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double maxHeight = MediaQuery.of(context).size.height;
    double maxWidth = MediaQuery.of(context).size.width;
    bool isTall = maxHeight > maxWidth * 0.85;
    double area = 0.8;
    double height = widget.height ?? maxHeight * area;
    // widget.height ?? (isTall ? maxWidth * area : maxHeight * area);
    double width = widget.width ?? maxWidth * area;
    width = isTall ? width : width * 0.75;
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      content: Container(
        height: height,
        width: width,
        child: SlideTransition(
          position: Tween<Offset>(
                  begin: Offset(0, (isTall ? maxWidth : maxHeight) / height),
                  end: Offset(0, 0))
              .animate(animation),
          child: BorderedContainer(
            label: "asdasdasdasd",
            shouldAnimateEntry: false,
            child: Container(
                height: height,
                width: width,
                color: secondaryColor,
                child: widget.child),
          ),
        ),
      ),
    );
  }
}
