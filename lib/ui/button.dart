import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class MyButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final Function() onPressed;
  final bool expanded;
  final double height;
  const MyButton({
    Key? key,
    required this.label,
    required this.onPressed,
    required this.expanded,
    required this.icon,
    required this.height,
  }) : super(key: key);

  Widget button() {
    return Container(
      width: 92,
      margin: EdgeInsets.symmetric(
          horizontal: 8, vertical: expanded ? 8 : (height / 18)),
      child: ElevatedButton.icon(
        icon: icon,
        label: AutoSizeText(
          label,
          maxLines: 1,
          minFontSize: 8,
        ),
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
