import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:slide_puzzle/code/audio.dart';
import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/code/service.dart';
import 'package:slide_puzzle/ui/bordered_container.dart';

class MyButton extends StatefulWidget {
  final String label;
  final TextStyle? labelStyle;
  final Widget? icon;
  final Function() onPressed;
  final bool expanded;
  final bool shouldAnimateEntry;
  final bool isDisabled;
  final String tooltip;
  // final double height;
  const MyButton({
    Key? key,
    required this.label,
    this.labelStyle,
    this.icon,
    required this.onPressed,
    required this.expanded,
    this.shouldAnimateEntry = true,
    this.isDisabled = false,
    required this.tooltip,
  }) : super(key: key);

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
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
        icon: widget.icon ?? Container(),
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
    Widget text() => AutoSizeText(
          widget.label,
          style: widget.labelStyle ?? TextStyle(color: Colors.white),
          maxLines: 1,
          minFontSize: 8,
        );
    return Tooltip(
      message: widget.tooltip,
      // triggerMode: TooltipTriggerMode.manual,
      child: Container(
        // height: 32,
        constraints: const BoxConstraints(maxHeight: 40, maxWidth: 96),
        // width: 96,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(4),
        child: GestureDetector(
          onTap: () {
            // print("tap");
            // AudioService.instance.buttonDown();
            animationController.forward().then((value) {
              animationController.reverse();
              // AudioService.instance.buttonUp();
            });
          },
          onTapDown: (_) {
            // print("down");
            shouldExecute = true;
            AudioService.instance.buttonDown();
            animationController.forward();
          },
          onPanStart: (details) {
            // print("pan start");
            if (!shouldExecute) AudioService.instance.buttonDown();
            shouldExecute = true;
            animationController.forward();
          },
          onPanUpdate: _onUpdate,
          onLongPressMoveUpdate: _onUpdate,
          onTapUp: (_) {
            // print("up");
            AudioService.instance.buttonUp();
            animationController.reverse();
            if (!widget.isDisabled) {
              widget.onPressed();
              AudioService.instance.vibrate();
            }
          },
          onLongPressUp: () {
            // print("long up");
            AudioService.instance.buttonUp();
            animationController.reverse();
            if (shouldExecute && !widget.isDisabled) {
              widget.onPressed();
              AudioService.instance.vibrate();
            }
          },
          onPanEnd: (_) {
            // print("pan end ${_.velocity.pixelsPerSecond.distance}");
            // setState(() => isPressed = false);
            AudioService.instance.buttonUp();
            animationController.reverse();
            if (shouldExecute && !widget.isDisabled) {
              widget.onPressed();
              AudioService.instance.vibrate();
            }
          },
          child: BorderedContainer(
            key: _buttonKey,
            label: widget.label,
            spacing: 5,
            color: buttonShadowColor,
            // isBottom: false,
            // isRight: true,
            // animationController: animationController,
            shouldAnimateEntry: widget.shouldAnimateEntry,
            buttonController: (controller) async {
              animationController = controller;
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  // border: Border.all(color: primaryColor),
                  // color: widget.isDisabled ? Colors.grey : primaryColor),
                  color: primaryColor),
              child: ClipRRect(
                borderRadius: borderRadius,
                child: MouseRegion(
                  onEnter: (event) {
                    if (!widget.isDisabled) setState(() => isHovering = true);
                  },
                  onExit: (event) {
                    if (!widget.isDisabled) setState(() => isHovering = false);
                  },
                  cursor: widget.isDisabled
                      ? SystemMouseCursors.basic
                      : SystemMouseCursors.click,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      widget.icon != null
                          ? animatedSwitcher(
                              child: isHovering
                                  ? Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: widget.icon,
                                    )
                                  : Container(),
                              offset: const Offset(0, -2),
                            )
                          : text(),
                      widget.icon != null
                          ? animatedSwitcher(
                              child: isHovering ? Container() : text(),
                              offset: const Offset(0, 2),
                            )
                          : Container(),
                    ],
                  ),
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
    if (configProvider.previewedButtons[widget.label] == null ||
        !configProvider.previewedButtons[widget.label]!) {
      if (widget.label == "Reset") return;
      await Future.delayed(Duration(milliseconds: 2000 + defaultEntryTime));
      if (this.mounted) {
        setState(() {
          isHovering = true;
        });
      }
      await Future.delayed(const Duration(milliseconds: 1500));
      if (this.mounted) {
        setState(() {
          isHovering = false;
        });
      }
      configProvider.seenButton(widget.label);
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

    // animationController = AnimationController(
    //     duration: Duration(milliseconds: 100),
    //     vsync: this,
    //     value: 0,
    //     lowerBound: 0,
    //     upperBound: 1);
  }

  @override
  Widget build(BuildContext context) {
    if (height != 0) getSizeAndPosition();
    if (widget.isDisabled) {
      // animationController.forward();
      // print("4 ${animationController.value}");
    }
    if (widget.expanded) {
      return Expanded(
        child: customButton(),
      );
    }
    return customButton();
  }
}
