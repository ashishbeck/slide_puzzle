import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:slide_puzzle/code/audio.dart';

import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/code/providers.dart';

class PuzzleImageThumbnail extends StatefulWidget {
  final bool isTall;
  final double size;
  final double padding;
  final int index;
  final ConfigProvider configProvider;
  final TileProvider tileProvider;
  const PuzzleImageThumbnail({
    Key? key,
    required this.isTall,
    required this.size,
    required this.padding,
    required this.index,
    required this.configProvider,
    required this.tileProvider,
  }) : super(key: key);

  @override
  _PuzzleImageThumbnailState createState() => _PuzzleImageThumbnailState();
}

class _PuzzleImageThumbnailState extends State<PuzzleImageThumbnail>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  bool isHovering = false;
  late Image image;

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
        .then((value) {
      if (mounted) {
        animationController.forward();
        if (widget.index == 0) {
          AudioService.instance.bubbles();
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animateEntry();
    image = Image.asset(
      widget.tileProvider.images[widget.index],
      fit: BoxFit.cover,
      height: 75,
      width: 75,
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(image.image, context);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
          parent: animationController, curve: Curves.easeOutBack),
      child: MouseRegion(
        onEnter: (event) => setState(() => isHovering = true),
        onExit: (event) => setState(() => isHovering = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            widget.tileProvider.changeImage(widget.index);
            AudioService.instance.button();
            AudioService.instance.vibrate();
          },
          child: Container(
            width:
                widget.isTall ? widget.size - widget.padding * 2 : widget.size,
            height:
                widget.isTall ? widget.size : widget.size - widget.padding * 2,
            decoration: BoxDecoration(
              border: Border.all(
                color: isHovering ? Colors.white : primaryColor,
                width: isHovering ? 3 : 1,
              ),
              // image: DecorationImage(
              //     image: AssetImage(widget.tileProvider.images[widget.index]),
              //     fit: BoxFit.cover),
              // borderRadius: const BorderRadius.all(
              //   Radius.circular(10),
              // ),
            ),
            child: image,
            // child: Text(widget.tileProvider.images[widget.index]),
            // child: Lottie.asset(
            //   widget.tileProvider.images[widget.index],
            //   animate: false,
            // ),
          ),
        ),
      ),
    );
  }
}
