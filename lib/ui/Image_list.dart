import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slide_puzzle/code/constants.dart';

import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/code/service.dart';
import 'package:slide_puzzle/ui/bordered_container.dart';
import 'package:slide_puzzle/ui/delayed_loader.dart';
import 'package:slide_puzzle/ui/puzzle_image_thumbnail.dart';

class ImageList extends StatefulWidget {
  final BoxConstraints constraints;
  final bool isTall;
  final Function(bool toggle) toggleImageList;
  final bool isVisible;
  const ImageList({
    Key? key,
    required this.constraints,
    this.isTall = false,
    required this.toggleImageList,
    required this.isVisible,
  }) : super(key: key);

  @override
  _ImageListState createState() => _ImageListState();
}

class _ImageListState extends State<ImageList>
    with SingleTickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  late Animation<double> animation;
  late AnimationController animationController;
  bool isScrollControllerAttached = false;

  Widget excessScrollIndicator(double size, {required bool isLeft}) {
    double max = scrollController.hasClients
        ? scrollController.position.maxScrollExtent
        : 100;
    double offset = scrollController.hasClients ? scrollController.offset : 0;
    double area = 60;
    return Align(
      alignment: widget.isTall
          ? isLeft
              ? Alignment.centerLeft
              : Alignment.centerRight
          : isLeft
              ? Alignment.topCenter
              : Alignment.bottomCenter,
      child: Container(
        height: widget.isTall
            ? size
            : isLeft
                ? offset < 0
                    ? 0
                    : offset > area
                        ? area
                        : offset
                : offset > max
                    ? 0
                    : offset < max - area
                        ? area
                        : max - offset,
        width: widget.isTall
            ? isLeft
                ? offset < 0
                    ? 0
                    : offset > area
                        ? area
                        : offset
                : offset > max
                    ? 0
                    : offset < max - area
                        ? area
                        : max - offset
            : size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              secondaryColor.withOpacity(isLeft ? 1 : 0),
              secondaryColor.withOpacity(isLeft ? 0 : 1),
            ],
            begin: widget.isTall ? Alignment.centerLeft : Alignment.topCenter,
            end: widget.isTall ? Alignment.centerRight : Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  _scrollListener() {
    if (scrollController.hasClients && !isScrollControllerAttached) {
      print("Attached");
      isScrollControllerAttached = true;
      scrollController.jumpTo(1);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: Duration(milliseconds: defaultTime),
        vsync: this,
        value: 0,
        lowerBound: 0,
        upperBound: 0.5);
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut);

    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    animationController.dispose();
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVisible) {
      animationController.reverse();
    } else {
      animationController.forward();
    }
    // print(animation.value);
    TileProvider tileProvider = context.read<TileProvider>();
    ConfigProvider configProvider = context.read<ConfigProvider>();
    double buttonSize = 25;
    double size = 100;
    double height = widget.isTall ? size : widget.constraints.maxHeight;
    double width = widget.isTall ? widget.constraints.maxWidth : size;
    double padding = 8;
    return DelayedLoader(
      configProvider: configProvider,
      duration: Duration(milliseconds: defaultSidebarTime),
      label: "imageListMain",
      child: Stack(
        alignment:
            widget.isTall ? Alignment.bottomCenter : Alignment.centerRight,
        clipBehavior: Clip.none,
        children: [
          Container(
            height: height + buttonSize,
            width: width + buttonSize,
            color: Colors.transparent,
          ),
          Container(
            height: height,
            width: width,
            child: BorderedContainer(
              isBottom: !widget.isTall,
              isRight: widget.isTall,
              label: "imageList",
              child: Container(
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  color: secondaryColor,
                  // borderRadius: BorderRadius.only(
                  //   topLeft: const Radius.circular(0),
                  //   bottomLeft:
                  //       widget.isTall ? Radius.zero : const Radius.circular(0),
                  //   topRight:
                  //       widget.isTall ? const Radius.circular(0) : Radius.zero,
                  //   bottomRight: Radius.zero,
                  // ),
                  // border: Border.all(
                  //   color: Colors.red,
                  // ),
                ),
                child: ScrollConfiguration(
                  behavior: MyCustomScrollBehavior(),
                  child: Scrollbar(
                    controller: scrollController,
                    child: Stack(
                      children: [
                        ListView.separated(
                          controller: scrollController,
                          itemCount: tileProvider.images.length,
                          scrollDirection:
                              widget.isTall ? Axis.horizontal : Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          separatorBuilder: (context, index) => Container(
                            padding: const EdgeInsets.all(2),
                          ),
                          itemBuilder: (context, index) {
                            return DelayedLoader(
                              duration: Duration(
                                  milliseconds: defaultEntryTime + index * 50),
                              configProvider: configProvider,
                              label: "image$index",
                              preload: true,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () =>
                                      tileProvider.changeImage(index + 1),
                                  child: PuzzleImageThumbnail(
                                      isTall: widget.isTall,
                                      size: size,
                                      padding: padding,
                                      index: index,
                                      configProvider: configProvider),
                                ),
                              ),
                            );
                          },
                        ),
                        scrollController.hasClients
                            ? excessScrollIndicator(size, isLeft: true)
                            : Container(),
                        // scrollController.hasClients
                        excessScrollIndicator(size, isLeft: false),
                        // : Container(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: widget.isTall ? null : -0,
            right: null,
            top: widget.isTall ? -0 : null,
            bottom: null,
            child: Container(
              height: buttonSize,
              width: buttonSize,
              child: BorderedContainer(
                label: "collapseButton",
                spacing: 4,
                isBottom: !widget.isTall,
                isRight: widget.isTall,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => widget.toggleImageList(!widget.isVisible),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      // height: buttonSize,
                      // width: buttonSize,
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(0),
                          ),
                          color: secondaryColor),
                      child: RotationTransition(
                        turns: animation,
                        child: Icon(
                          widget.isTall
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_right,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
