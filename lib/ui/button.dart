import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:slide_puzzle/code/providers.dart';
import 'package:provider/provider.dart';

class MyButton extends StatefulWidget {
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

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  final duration = const Duration(milliseconds: 250);
  final curve = Curves.easeInOutCirc;
  final borderRadius = const BorderRadius.all(Radius.circular(30));
  bool isHovering = false;

  Widget button() {
    return Container(
      width: 92,
      margin: EdgeInsets.symmetric(
          horizontal: 8, vertical: widget.expanded ? 8 : (widget.height / 18)),
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

  Widget customButton() {
    return Container(
      // height: 32,
      constraints: const BoxConstraints(maxHeight: 40, maxWidth: 96),
      // width: 96,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(color: Theme.of(context).primaryColor),
          color: const Color(0xff222222)),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: MouseRegion(
          onEnter: (event) => setState(() => isHovering = true),
          onExit: (event) => setState(() => isHovering = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onPressed,
            child: Stack(
              alignment: Alignment.center,
              children: [
                animatedSwitcher(
                  child: isHovering ? widget.icon : Container(),
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

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
    _preview();
    // });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.expanded) {
      return Expanded(
        child: customButton(),
      );
    }
    return customButton();
  }
}
