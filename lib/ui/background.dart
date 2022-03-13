import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/code/providers.dart';

class BackgroundBox extends StatefulWidget {
  final double size;
  final Offset offset;
  final ConfigProvider configProvider;
  const BackgroundBox({
    Key? key,
    required this.size,
    required this.offset,
    required this.configProvider,
  }) : super(key: key);

  @override
  State<BackgroundBox> createState() => _BackgroundBoxState();
}

class _BackgroundBoxState extends State<BackgroundBox>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  Duration duration = const Duration(milliseconds: 500);
  Timer? timer;
  // Size? _windowSize;
  var rand = Random();
  // double x = 0;
  // double y = 0;
  bool xAnim = false;
  bool yAnim = false;
  bool _aiSolving = false;

  // _listener() {
  //   // print(animation.value);
  //   setState(() {
  //     x = xAnim ? 3 * (controller.value) : 0;
  //     y = yAnim ? 3 * (controller.value) : 0;
  //   });
  // }

  _animate() {
    timer = Timer.periodic(
        _aiSolving ? (controller.duration! * 1.1) : const Duration(seconds: 2),
        (timer) {
      bool random = rand.nextDouble() < 0.5;
      if ((random || _aiSolving) && mounted) {
        if (mounted) {
          if (!_aiSolving) {
            xAnim = !xAnim;
            yAnim = !xAnim;
          } else {
            if (random) {
              xAnim = !xAnim;
              yAnim = !xAnim;
            }
          }
          // controller.duration = duration * (1 - 0.5 * random);
          controller.forward().then((value) {
            if (mounted) {
              controller.value = 0;
            }
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: duration);
    // controller.addListener(_listener);
    // controller.repeat(reverse: false);
    xAnim = (widget.offset.dx * widget.offset.dy) % 4 == 0;
    yAnim = !xAnim;
    _animate();
  }

  @override
  void dispose() {
    // controller.removeListener(_listener);
    controller.dispose();
    if (timer != null) timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // double left = (widget.index * (widget.size + 10)).toDouble();
    // double top = (widget.index * (widget.size + 10)).toDouble();
    // final windowSize = MediaQuery.of(context).size;
    // _windowSize ??= windowSize;
    // Duration duration = windowSize != _windowSize
    //     ? Duration.zero
    //     : Duration(milliseconds: defaultTime);
    // _windowSize = windowSize;
    ConfigProvider configProvider = context.watch<ConfigProvider>();

    bool aiSolving = configProvider.gamestate == GameState.aiSolving;
    if (aiSolving != _aiSolving) {
      _aiSolving = aiSolving;
      if (timer != null) {
        timer!.cancel();
        _animate();
      }
    }
    // if (!aiSolving) {
    // } else {
    //   _animate();
    // }

    final offset = widget.offset;
    final size = widget.size;
    return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Positioned(
            // duration: duration,
            // curve: Curves.easeOutCirc,
            left: offset.dx * size,
            top: offset.dy * size,
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2,
                    0.01) // col = 2, row = 3 & 0.003 = depth perception in the Z direction
                ..rotateX(xAnim ? 3 * (controller.value) : 0)
                ..rotateY(yAnim ? 3 * (controller.value) : 0),
              child: CustomPaint(
                painter: BoxPainter(),
                child: SizedBox(
                  height: size / 2,
                  width: size / 2,
                ),
              ),
            ),
          );
        });
  }
}

class BoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = secondaryColor.withOpacity(0.2)
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
