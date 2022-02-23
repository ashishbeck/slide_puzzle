import 'package:flutter/material.dart';

import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/code/providers.dart';

class PuzzleImageThumbnail extends StatefulWidget {
  final bool isTall;
  final double size;
  final double padding;
  final int index;
  final ConfigProvider configProvider;
  const PuzzleImageThumbnail({
    Key? key,
    required this.isTall,
    required this.size,
    required this.padding,
    required this.index,
    required this.configProvider,
  }) : super(key: key);

  @override
  _PuzzleImageThumbnailState createState() => _PuzzleImageThumbnailState();
}

class _PuzzleImageThumbnailState extends State<PuzzleImageThumbnail>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  bool _ifAnimated() {
    String name = "imageIndEntry${widget.index}";
    if (widget.configProvider.entryAnimationDone[name] != null &&
        widget.configProvider.entryAnimationDone[name]!) {
      return true;
    }
    widget.configProvider.seenEntryAnimation(name);
    return false;
  }

  _animateEntry() async {
    if (_ifAnimated()) {
      animationController.value = 1;
      return;
    }
    Future.delayed(Duration(milliseconds: defaultEntryTime + widget.index * 50))
        .then((value) => animationController.forward());
  }

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animateEntry();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
          parent: animationController, curve: Curves.easeOutBack),
      child: Container(
        width: widget.isTall ? widget.size - widget.padding * 2 : widget.size,
        height: widget.isTall ? widget.size : widget.size - widget.padding * 2,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/pexels_${widget.index + 1}.jpg"),
              fit: BoxFit.cover),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        // child: Image(
        //   image: AssetImage("images/pexels_${index + 1}.jpg"),
        // ),
      ),
    );
  }
}
