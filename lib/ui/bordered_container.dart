import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/code/providers.dart';

class BorderedContainer extends StatefulWidget {
  final String label;
  final Widget child;
  final double spacing;
  final Color? color;
  final bool isBottom;
  final bool isRight;
  final bool shouldAnimateEntry;
  // final AnimationController? animationController;
  final Function(AnimationController controller)? buttonController;
  const BorderedContainer({
    Key? key,
    // this.animationController,
    required this.label,
    required this.child,
    this.spacing = 10,
    this.color,
    this.isBottom = true,
    this.isRight = true,
    this.shouldAnimateEntry = true,
    this.buttonController,
  }) : super(key: key);

  @override
  State<BorderedContainer> createState() => _BorderedContainerState();
}

class _BorderedContainerState extends State<BorderedContainer>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late AnimationController buttonController;
  bool isAnimatingBase = true;
  Duration buttonDuration = Duration(milliseconds: 100);

  _animateBase() async {
    ConfigProvider configProvider = context.read<ConfigProvider>();
    if (configProvider.entryAnimationDone[widget.label] != null &&
        configProvider.entryAnimationDone[widget.label]!) {
      isAnimatingBase = false;
      return;
    }
    buttonController.value = 1;
    if (widget.label == "3x3" || widget.label == "4x4") {
      configProvider.seenEntryAnimation("3x3");
      configProvider.seenEntryAnimation("4x4");
    }
    configProvider.seenEntryAnimation(widget.label);
    controller.forward().then((value) => setState(() {
          isAnimatingBase = false;
          buttonController.duration = Duration(milliseconds: 200);
          buttonController
              .reverse()
              .then((value) => buttonController.duration = buttonDuration);
        }));
  }

  @override
  void initState() {
    super.initState();
    buttonController =
        AnimationController(vsync: this, duration: buttonDuration);
    if (widget.buttonController != null) {
      widget.buttonController!(buttonController);
    }
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: defaultEntryTime));
    if (widget.shouldAnimateEntry) {
      _animateBase();
    } else {
      // setState(() {
      isAnimatingBase = false;
      // });
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    buttonController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        // height: height + 50,
        // width: width + 50,
        child: isAnimatingBase
            ? ClipPath(
                clipper: CustomClipperShape(
                  isBottom: widget.isBottom,
                  isRight: widget.isRight,
                  spacing: widget.spacing,
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: const Offset(0, 0),
                  ).animate(
                    CurvedAnimation(
                        parent: controller, curve: Curves.easeInOutSine),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        bottom: widget.isBottom ? -widget.spacing : null,
                        top: widget.isBottom ? null : -widget.spacing,
                        right: widget.isRight ? -widget.spacing : null,
                        left: widget.isRight ? null : -widget.spacing,
                        child: Container(
                            height: constraints.maxHeight,
                            width: constraints.maxWidth,
                            color: widget.buttonController != null
                                ? primaryColor
                                : secondaryColor),
                      ),
                    ],
                  ),
                ),
              )
            : Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomRight,
                children: [
                  Positioned(
                    bottom: widget.isBottom ? -widget.spacing : null,
                    top: widget.isBottom ? null : -widget.spacing,
                    right: widget.isRight ? -widget.spacing : null,
                    left: widget.isRight ? null : -widget.spacing,
                    child: CustomPaint(
                      painter: MyFrameShape(
                        spacing: widget.spacing,
                        color: widget.color ?? primaryColor,
                        isBottom: widget.isBottom,
                        isRight: widget.isRight,
                        animationController: buttonController,
                      ),
                      child: Container(
                        height: constraints.maxHeight,
                        width: constraints.maxWidth,
                      ),
                    ),
                  ),
                  (widget.buttonController != null || widget.shouldAnimateEntry)
                      ? SlideTransition(
                          position: Tween<Offset>(
                                  begin: const Offset(0, 0),
                                  end: Offset(
                                      (widget.isRight
                                              ? widget.spacing
                                              : -widget.spacing) /
                                          constraints.maxWidth,
                                      (widget.isBottom
                                              ? widget.spacing
                                              : -widget.spacing) /
                                          constraints.maxHeight))
                              .animate(buttonController),
                          child: widget.child)
                      : widget.child,
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

    Path bottomRight = Path()
      ..moveTo(-spacing * animationOffset, -spacing * animationOffset)
      ..lineTo(width - spacing * animationOffset, -spacing * animationOffset)
      ..lineTo(width, 0) // (width, spacing)
      ..lineTo(width, height)
      ..lineTo(0, height) // (spacing, height)
      ..lineTo(-spacing * animationOffset, height - spacing * animationOffset)
      ..lineTo(-spacing * animationOffset, -spacing * animationOffset)
      ..close();

    if (isBottom && isRight) canvas.drawPath(bottomRight, paint_0);

    // Paint bottomLeft = Paint()
    //   ..color = color
    //   ..style = PaintingStyle.fill
    //   ..strokeWidth = 0.5;

    Path bottomLeft = Path()
      ..moveTo(0, 0)
      ..lineTo(spacing * animationOffset, -spacing * animationOffset)
      ..lineTo(width + spacing * animationOffset, -spacing * animationOffset)
      ..lineTo(
          width + spacing * animationOffset, height - spacing * animationOffset)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..lineTo(0, 0);

    if (isBottom && !isRight) canvas.drawPath(bottomLeft, paint_0);

    Path topRight = Path()
      ..moveTo(-spacing * animationOffset, spacing * animationOffset)
      ..lineTo(0, 0)
      ..lineTo(width, 0)
      ..lineTo(width, height)
      ..lineTo(
          width - spacing * animationOffset, height + spacing * animationOffset)
      ..lineTo(-spacing * animationOffset, height + spacing * animationOffset)
      ..lineTo(-spacing * animationOffset, spacing * animationOffset);

    if (!isBottom && isRight) canvas.drawPath(topRight, paint_0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class CustomClipperShape extends CustomClipper<Path> {
  final double spacing;
  final bool isBottom;
  final bool isRight;
  CustomClipperShape({
    required this.spacing,
    required this.isBottom,
    required this.isRight,
  });

  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;

    var bottomRight = Path()
      ..moveTo(spacing, spacing)
      ..lineTo(width + spacing, spacing)
      ..lineTo(width + spacing, height + spacing)
      ..lineTo(0 + spacing, height + spacing)
      ..lineTo(0 + spacing, 0 + spacing)
      ..close();

    var bottomLeft = Path()
      ..moveTo(-spacing, spacing)
      ..lineTo(width - spacing, spacing)
      ..lineTo(width - spacing, height + spacing)
      ..lineTo(0 - spacing, height + spacing)
      ..lineTo(0 - spacing, 0 + spacing)
      ..close();

    var topRight = Path()
      ..moveTo(spacing, -spacing)
      ..lineTo(width + spacing, -spacing)
      ..lineTo(width + spacing, height - spacing)
      ..lineTo(0 + spacing, height - spacing)
      ..lineTo(0 + spacing, 0 - spacing)
      ..close();

    if (isBottom && isRight) {
      return bottomRight;
    } else if (isBottom && !isRight) {
      return bottomLeft;
    } else if (!isBottom && isRight) {
      return topRight;
    }
    return bottomRight;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
