import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/code/service.dart';
import 'package:slide_puzzle/screen/puzzle.dart';
import 'package:slide_puzzle/ui/button.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

class LayoutPage extends StatefulWidget {
  const LayoutPage({Key? key}) : super(key: key);

  @override
  _LayoutPageState createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> with TickerProviderStateMixin {
  late AnimationController controller;
  Duration duration = const Duration(milliseconds: 200);
  Curve curve = Curves.easeOut;
  double area = 0.75;
  double offsetFromCenter = 0.5;
  bool isTopLeft = true;

  void _createTiles() {
    bool isSolvable = false;
    int gridSize = 4;
    int totalTiles = pow(gridSize, 2).toInt();
    List<int> numbers = List.generate(totalTiles, (index) => index);
    List<TilesModel> list = [];
    List<int> random = List.from(numbers);
    while (!isSolvable) {
      random.shuffle();
      list = numbers
          .map((e) => TilesModel(
              defaultIndex: e,
              currentIndex: random[e],
              isWhite: e == totalTiles - 1))
          .toList();
      // List<TilesModel> list = List.generate(
      //     totalTiles,
      //     (index) => TilesModel(
      //         defaultIndex: index,
      //         currentIndex: index,
      //         isWhite: index == totalTiles - 1));
      // list.shuffle();
      isSolvable = Service().isSolvable(list);
    }
    TileProvider tileProvider = context.read<TileProvider>();
    tileProvider.createTiles(list);
    ConfigProvider configProvider = context.read<ConfigProvider>();
    var duration = const Duration(milliseconds: 500);
    configProvider.setDuration(duration, curve: Curves.easeInOutBack);
    Future.delayed(duration).then((value) => configProvider.resetDuration());
  }

  List<Widget> buttons(double height, {bool expanded = true}) => [
        MyButton(
          label: "Shuffle",
          icon: const Icon(Icons.shuffle),
          expanded: expanded,
          height: height,
          onPressed: _createTiles,
        ),
        // MyButton(
        //   label: "Reset",
        //   icon: const Icon(Icons.cancel),
        //   expanded: expanded,
        //   height: height,
        //   onPressed: () {},
        // ),
        MyButton(
          label: "Solve?",
          icon: const Icon(Icons.stars_sharp),
          expanded: expanded,
          height: height,
          onPressed: () {},
        ),
      ];

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, lowerBound: 0, upperBound: 1, duration: duration);
    controller.value = 1;
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _createTiles();
    });
    final isWebMobile = kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);
    if (isWebMobile) area = 0.9;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   child: const Icon(Icons.add),
      //   onPressed: () {
      //     // _createTiles();
      //     setState(() {
      //       isTopLeft = !isTopLeft;
      //     });
      //   },
      // ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // final size = constraints.
          double maxWidth = constraints.maxWidth;
          double maxHeight = constraints.maxHeight;
          bool isTall = maxWidth * 0.85 < maxHeight;
          double absoluteWidth = maxWidth * area;
          double absoluteHeight = maxHeight * area;
          double puzzleHeight = isTall ? absoluteWidth : absoluteHeight;
          double puzzleWidth = isTall ? absoluteWidth : absoluteHeight;

          // head scratcher below for a solid hour and still not perfect :(
          double bottomButtonOffset =
              (2 * puzzleHeight * area / maxHeight) - offsetFromCenter + 0.12;
          double rightButtonOffset =
              (2 * puzzleHeight * area / (maxWidth * 0.85)) -
                  offsetFromCenter +
                  0.12;
          //     ((puzzleWidth - (offsetFromCenter * maxWidth / 2)) *
          //         2 /
          //         maxWidth);
          // print(rightButtonOffset);

          // print("$maxWidth and $maxHeight");
          // bool isTall = (width / height) < (6 / 5);
          if (isTall) {
            // if (controller.value == 1 && !controller.isAnimating) {
            controller.forward();
            // }
          } else {
            controller.reverse();
          }
          double padding = 32;
          return Center(
            child: Container(
              color: Colors.amber.withOpacity(0.2),
              child: Stack(children: [
                AnimatedAlign(
                  duration: duration,
                  curve: curve,
                  alignment: isTall
                      ? Alignment(0, -offsetFromCenter)
                      : Alignment(-offsetFromCenter, 0),
                  // left: isTopLeft ? 20 : 0,
                  // right: !isTopLeft ? 23 : 0,
                  // top: isTopLeft ? 23 : 0,
                  // bottom: !isTopLeft ? 23 : 0,
                  child: AnimatedContainer(
                    duration: duration,
                    curve: curve,
                    padding: EdgeInsets.all(4),
                    color: Colors.green.withOpacity(isTall ? 0.4 : 1),
                    height: puzzleHeight,
                    width: puzzleWidth,
                    child: Puzzle(),
                    // height: constraints.biggest.height,
                    // width: constraints.maxWidth,
                  ),
                ),
                // if (kDebugMode)
                //   for (var i = 0; i < 10; i++) ...{
                //     ...[
                //       Positioned(
                //         top: maxHeight * i * 0.1,
                //         child: Text((i / 10).toString()),
                //       ),
                //       Positioned(
                //         left: maxWidth * i * 0.1,
                //         child: Text((i / 10).toString()),
                //       ),
                //     ]
                //   },
                //   Positioned(
                //     top: maxHeight * 0.25,
                //     child: Text((maxHeight * 0.25).toString()),
                //   ),
                // Positioned(
                //   top: maxHeight * 0.5,
                //   child: Text((maxHeight * 0.5).toString()),
                // ),
                // Positioned(
                //   top: maxHeight * 0.75,
                //   child: Text((maxHeight * 0.75).toString()),
                // ),

                // bottom buttons
                AnimatedAlign(
                  duration: duration,
                  curve: curve,
                  alignment: isTall
                      ? Alignment(0, bottomButtonOffset)
                      : Alignment(-bottomButtonOffset, bottomButtonOffset),
                  child: AnimatedContainer(
                    duration: duration,
                    curve: curve,
                    width: isTall ? puzzleWidth : puzzleWidth,
                    child: AnimatedSwitcher(
                      // opacity: controller.value,
                      duration: duration,
                      // curve: curve,
                      child: isTall
                          ? Row(
                              children: buttons(puzzleHeight, expanded: true),
                            )
                          : const SizedBox(
                              height: 44,
                            ),
                    ),
                  ),
                ),

                // right buttons
                AnimatedAlign(
                  duration: duration,
                  curve: curve,
                  alignment: isTall
                      ? Alignment(rightButtonOffset, -rightButtonOffset)
                      : Alignment(rightButtonOffset, 0),
                  child: AnimatedContainer(
                    duration: duration,
                    curve: curve,
                    // width: 200,
                    // height: isTall ? puzzleWidth : puzzleHeight,
                    child: AnimatedSwitcher(
                      // opacity: controller.value,
                      duration: duration,
                      // curve: curve,
                      child: !isTall
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: buttons(puzzleHeight, expanded: false),
                            )
                          : const SizedBox(
                              height: 44,
                            ),
                    ),
                  ),
                ),

                // legacy column second child
                // --------------------------
                // AnimatedSwitcher(
                //         // opacity: controller.value,
                //         duration: duration,
                //         // curve: curve,
                //         child: isTall
                //             ? Container(
                //                 width: isTall ? width : height,
                //                 // alignment: Alignment.bottomCenter,
                //                 child: Row(
                //                   children: buttons(expanded: true),
                //                 ),
                //               )
                //             : const SizedBox(
                //                 height: 44,
                //               ),
                //       )

                // legacy row second child
                // -----------------------
                // AnimatedSwitcher(
                //         // opacity: controller.value,
                //         duration: duration,
                //         // curve: curve,
                //         child: !isTall
                //             ? Container(
                //                 height: !isTall ? width : height,
                //                 // alignment: Alignment.bottomCenter,
                //                 child: Column(
                //                   crossAxisAlignment: CrossAxisAlignment.start,
                //                   children: buttons(expanded: false),
                //                 ),
                //               )
                //             : const SizedBox(
                //                 width: 44,
                //               ),
                //       )

                // AnimatedAlign(
                //   alignment: isTall
                //       ? Alignment(-offsetFromCenter * 0.5, offsetFromCenter)
                //       : Alignment(offsetFromCenter, -offsetFromCenter * 0.2),
                //   duration: duration,
                //   curve: curve,
                //   child: MyButton(
                //     child: const Text("Generate"),
                //     onPressed: () {},
                //   ),
                // ),
                // AnimatedAlign(
                //   alignment: isTall
                //       ? Alignment(0, offsetFromCenter)
                //       : Alignment(offsetFromCenter, 0),
                //   duration: duration,
                //   curve: curve,
                //   child: MyButton(
                //     child: const Text("Clear"),
                //     onPressed: () {},
                //   ),
                // ),
                // AnimatedAlign(
                //   alignment: isTall
                //       ? Alignment(offsetFromCenter * 0.5, offsetFromCenter)
                //       : Alignment(offsetFromCenter, offsetFromCenter * 0.2),
                //   duration: duration,
                //   curve: curve,
                //   child: MyButton(
                //     child: const Text("Solve?"),
                //     onPressed: () {},
                //   ),
                // ),
              ]),
            ),
          );
        },
      ),
    );
  }
}
