import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:slide_puzzle/code/constants.dart';

class BorderedContainer extends StatelessWidget {
  final Widget child;
  final double spacing;
  final Color? color;
  final bool isBottom;
  final bool isRight;
  final bool isButton;
  final AnimationController? animationController;
  const BorderedContainer({
    Key? key,
    required this.child,
    this.spacing = 10,
    this.color,
    this.isBottom = true,
    this.isRight = true,
    this.isButton = false,
    this.animationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        // height: height + 50,
        // width: width + 50,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomRight,
          children: [
            Positioned(
              bottom: isBottom ? -spacing : null,
              top: isBottom ? null : -spacing,
              right: isRight ? -spacing : null,
              left: isRight ? null : -spacing,
              child: CustomPaint(
                painter: MyFrameShape(
                  spacing: spacing,
                  color: color ?? primaryColor,
                  isBottom: isBottom,
                  isRight: isRight,
                  animationController: animationController,
                ),
                child: Container(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                ),
              ),
            ),
            animationController != null
                ? SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0),
                            end: Offset(spacing / constraints.maxWidth,
                                spacing / constraints.maxHeight))
                        .animate(animationController!),
                    child: child)
                : child,
          ],
        ),
      );
    });
  }
}

class MyFrameShape extends CustomPainter {
  final double spacing;
  final Color? color;
  final bool isBottom;
  final bool isRight;
  final AnimationController? animationController;
  MyFrameShape({
    this.spacing = 10,
    this.color,
    this.isBottom = true,
    this.isRight = true,
    this.animationController,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double height = size.height;
    double width = size.width;

    Paint paint_0 = Paint()
      ..color = color ?? primaryColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 0.5;

    double animationOffset =
        animationController != null ? (1 - animationController!.value) : 1;

    Path bottomRight = Path();
    bottomRight.moveTo(-spacing * animationOffset, -spacing * animationOffset);
    bottomRight.lineTo(
        width - spacing * animationOffset, -spacing * animationOffset);
    bottomRight.lineTo(width, 0); // (width, spacing)
    bottomRight.lineTo(width, height);
    bottomRight.lineTo(0, height); // (spacing, height)
    bottomRight.lineTo(
        -spacing * animationOffset, height - spacing * animationOffset);
    bottomRight.lineTo(-spacing * animationOffset, -spacing * animationOffset);
    bottomRight.close();

    if (isBottom && isRight) canvas.drawPath(bottomRight, paint_0);

    // Paint bottomLeft = Paint()
    //   ..color = color
    //   ..style = PaintingStyle.fill
    //   ..strokeWidth = 0.5;

    Path bottomLeft = Path();
    bottomLeft.moveTo(0, 0);
    bottomLeft.lineTo(spacing, -spacing);
    bottomLeft.lineTo(width + spacing, -spacing);
    bottomLeft.lineTo(width + spacing, height - spacing);
    bottomLeft.lineTo(width, height);
    bottomLeft.lineTo(0, height);
    bottomLeft.lineTo(0, 0);

    if (isBottom && !isRight) canvas.drawPath(bottomLeft, paint_0);

    Path topRight = Path();
    topRight.moveTo(0, 0);
    topRight.lineTo(width, 0);
    topRight.lineTo(width, height);
    topRight.lineTo(width - spacing, height + spacing);
    topRight.lineTo(-spacing, height + spacing);
    topRight.lineTo(-spacing, spacing);
    topRight.lineTo(0, 0);

    if (!isBottom && isRight) canvas.drawPath(topRight, paint_0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
