import 'package:flutter/material.dart';
import 'package:slide_puzzle/code/providers.dart';
import 'package:provider/provider.dart';
import 'package:slide_puzzle/code/service.dart';

class ImageList extends StatefulWidget {
  final BoxConstraints constraints;
  final bool isTall;
  const ImageList({
    Key? key,
    required this.constraints,
    this.isTall = false,
  }) : super(key: key);

  @override
  _ImageListState createState() => _ImageListState();
}

class _ImageListState extends State<ImageList> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    TileProvider tileProvider = context.read<TileProvider>();
    double size = 100;
    double padding = 8;
    return Container(
      height: widget.isTall ? size : widget.constraints.maxHeight,
      width: widget.isTall ? widget.constraints.maxWidth : size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10),
          bottomLeft: widget.isTall ? Radius.zero : const Radius.circular(10),
          topRight: widget.isTall ? const Radius.circular(10) : Radius.zero,
          bottomRight: Radius.zero,
        ),
        // border: Border.all(
        //   color: Colors.red,
        // ),
      ),
      child: ScrollConfiguration(
        behavior: MyCustomScrollBehavior(),
        child: Scrollbar(
          controller: scrollController,
          child: ListView.separated(
              controller: scrollController,
              itemCount: tileProvider.images.length,
              scrollDirection: widget.isTall ? Axis.horizontal : Axis.vertical,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (context, index) => Container(
                    padding: const EdgeInsets.all(2),
                  ),
              itemBuilder: (context, index) {
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => tileProvider.changeImage(index + 1),
                    child: Container(
                      width: widget.isTall ? size - padding * 2 : size,
                      height: widget.isTall ? size : size - padding * 2,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("images/pexels_${index + 1}.jpg"),
                            fit: BoxFit.cover),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      // child: Image(
                      //   image: AssetImage("images/pexels_${index + 1}.jpg"),
                      // ),
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
