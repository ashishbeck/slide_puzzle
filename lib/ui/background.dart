import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:slide_puzzle/code/constants.dart';

class BackgroundBox extends StatefulWidget {
  final double size;
  final Offset offset;
  const BackgroundBox({
    Key? key,
    required this.size,
    required this.offset,
  }) : super(key: key);

  @override
  State<BackgroundBox> createState() => _BackgroundBoxState();
}

class _BackgroundBoxState extends State<BackgroundBox> {
  Size? _windowSize;
  var rand = Random();
  bool? isInvisible;
  @override
  Widget build(BuildContext context) {
    // double left = (widget.index * (widget.size + 10)).toDouble();
    // double top = (widget.index * (widget.size + 10)).toDouble();
    final windowSize = MediaQuery.of(context).size;
    _windowSize ??= windowSize;
    Duration duration = windowSize != _windowSize
        ? Duration.zero
        : Duration(milliseconds: defaultTime);
    _windowSize = windowSize;
    final offset = widget.offset;
    final size = widget.size;
    isInvisible ??= rand.nextDouble() < 0.0;
    return isInvisible ?? true
        ? Container()
        : AnimatedPositioned(
            duration: duration,
            curve: Curves.easeOutCirc,
            left: offset.dx * size,
            top: offset.dy * size,
            child: CustomPaint(
              painter: BoxPainter(),
              child: SizedBox(
                height: size / 2,
                width: size / 2,
              ),
            ),
          );
  }
}

class BoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Color.fromARGB(255, 194, 166, 164)
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.5;

    canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero, width: size.width, height: size.height),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
