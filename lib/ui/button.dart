import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/code/providers.dart';
import 'package:provider/provider.dart';
import 'package:slide_puzzle/ui/bordered_container.dart';

class MyButton extends StatefulWidget {
  final String label;
  final Widget icon;
  final Function() onPressed;
  final bool expanded;
  // final double height;
  const MyButton({
    Key? key,
    required this.label,
    required this.onPressed,
    required this.expanded,
    required this.icon,
    // required this.height,
  }) : super(key: key);

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton>
    with SingleTickerProviderStateMixin {
  final GlobalKey _buttonKey = GlobalKey();
  late AnimationController animationController;
  final duration = const Duration(milliseconds: 250);
  final curve = Curves.easeInOutCirc;
  final borderRadius = const BorderRadius.all(Radius.circular(0));
  bool isHovering = false;
  bool isPressed = false;
  Offset origin = const Offset(0, 0);
  bool shouldExecute = true;
  double height = 0;
  double width = 0;

  Widget button() {
    return Container(
      width: 92,
      // margin: EdgeInsets.symmetric(
      //     horizontal: 8, vertical: widget.expanded ? 8 : (widget.height / 18)),
      child: ElevatedButton.icon(
        icon: widget.icon,
        label: AutoSizeText(
          widget.label,
          maxLines: 1,
          minFontSize: 8,
        ),
        onPressed: widget.onPressed,
      ),
    );
  }

  Widget animatedSwitcher({required Widget child, required Offset offset}) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      child: child,
      transitionBuilder: (Widget child2, Animation<double> animation2) {
        return SlideTransition(
          child: child2,
          position: Tween<Offset>(begin: offset, end: const Offset(0, 0))
              .animate(animation2),
        );
      },
      // layoutBuilder: (currentChild, previousChildren) {
      //   return OverflowBox();
      // },
    );
  }

  void _onUpdate(var details) {
    Offset newPos = details.localPosition;
    var dx = newPos.dx;
    var dy = newPos.dy;
    if (!dx.isNegative && !dy.isNegative && (dx < width && dy < height)) {
      shouldExecute = true;
    } else {
      shouldExecute = false;
    }
  }

  Widget customButton() {
    return Container(
      // height: 32,
      constraints: const BoxConstraints(maxHeight: 40, maxWidth: 96),
      // width: 96,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: () {
          animationController
              .forward()
              .then((value) => animationController.reverse());
        },
        onTapDown: (_) {
          // print("down");
          shouldExecute = true;
          animationController.forward();
        },
        onPanStart: (details) {
          // print("pan start");
          shouldExecute = true;
          animationController.forward();
        },
        onPanUpdate: _onUpdate,
        onLongPressMoveUpdate: _onUpdate,
        onTapUp: (_) {
          // print("up");
          animationController.reverse();
          widget.onPressed();
        },
        onLongPressUp: () {
          // print("long up");
          animationController.reverse();
          if (shouldExecute) widget.onPressed();
        },
        onPanEnd: (_) {
          // print("pan end ${_.velocity.pixelsPerSecond.distance}");
          // setState(() => isPressed = false);
          animationController.reverse();
          if (shouldExecute) widget.onPressed();
        },
        child: BorderedContainer(
          key: _buttonKey,
          spacing: 5,
          color: secondaryColor[700],
          animationController: animationController,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: borderRadius,
                // border: Border.all(color: primaryColor),
                color: primaryColor),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: MouseRegion(
                onEnter: (event) => setState(() => isHovering = true),
                onExit: (event) => setState(() => isHovering = false),
                cursor: SystemMouseCursors.click,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    animatedSwitcher(
                      child: isHovering
                          ? Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: widget.icon,
                            )
                          : Container(),
                      offset: const Offset(0, -2),
                    ),
                    animatedSwitcher(
                      child: isHovering
                          ? Container()
                          : AutoSizeText(
                              widget.label,
                              style: const TextStyle(color: Colors.white),
                              maxLines: 1,
                              minFontSize: 8,
                            ),
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _preview() async {
    final configProvider = context.read<ConfigProvider>();
    if (!configProvider.previewedButtons) {
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        isHovering = true;
      });
      await Future.delayed(const Duration(milliseconds: 1500));
      setState(() {
        isHovering = false;
      });
      configProvider.seenButton();
    }
  }

  getSizeAndPosition() {
    RenderBox box = _buttonKey.currentContext!.findRenderObject() as RenderBox;
    height = (box.size.height);
    width = (box.size.width);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => getSizeAndPosition());
    _preview();

    animationController = AnimationController(
        duration: Duration(milliseconds: 100),
        vsync: this,
        value: 0,
        lowerBound: 0,
        upperBound: 1);
  }

  @override
  Widget build(BuildContext context) {
    if (height != 0) getSizeAndPosition();
    if (widget.expanded) {
      return Expanded(
        child: customButton(),
      );
    }
    return customButton();
  }
}
