import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:slide_puzzle/code/audio.dart';
import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/code/service.dart';
import 'package:slide_puzzle/screen/puzzle.dart';
import 'package:slide_puzzle/ui/Image_list.dart';
import 'package:slide_puzzle/ui/button.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:slide_puzzle/ui/toolbar.dart';

class LayoutPage extends StatefulWidget {
  LayoutPage({Key? homekey}) : super(key: homeKey);

  @override
  _LayoutPageState createState() => _LayoutPageState();
}

final homeKey = GlobalKey<_LayoutPageState>();

class _LayoutPageState extends State<LayoutPage> with TickerProviderStateMixin {
  late AnimationController controller;
  int gridSize = 4;
  Duration duration = Duration(milliseconds: defaultTime);
  Curve curve = Curves.easeOut;
  double area = 0.75;
  double offsetFromCenter = 0.5;
  bool isTopLeft = true;

  void createTiles({int gridSize = 4, bool isChangingGrid = false}) {
    bool isSolvable = false;
    bool isAlreadySolved = false;
    int totalTiles = pow(gridSize, 2).toInt();
    List<int> numbers = List.generate(totalTiles, (index) => index);
    List<TilesModel> list = [];
    List<int> random = List.from(numbers);
    while (!isSolvable && !isAlreadySolved) {
      random.shuffle();
      list = numbers.map((e) {
        Coordinates coordinates = Coordinates(
            row: (random[e] / gridSize).floor(), column: random[e] % gridSize);
        return TilesModel(
            defaultIndex: e,
            currentIndex: random[e],
            coordinates: coordinates,
            isWhite: e == totalTiles - 1);
      }).toList();
      // List<TilesModel> list = List.generate(
      //     totalTiles,
      //     (index) => TilesModel(
      //         defaultIndex: index,
      //         currentIndex: index,
      //         isWhite: index == totalTiles - 1));
      // list.shuffle();
      isSolvable = Service().isSolvable(list);
      isAlreadySolved = Service().isSolved(list);
    }
    TileProvider tileProvider = context.read<TileProvider>();
    if (tileProvider.getTileList.isNotEmpty) {
      AudioService.instance.shuffle();
      Service().vibrate();
    }
    tileProvider.createTiles(list);
    ConfigProvider configProvider = context.read<ConfigProvider>();
    var duration = Duration(milliseconds: isChangingGrid ? 10 : 500);
    configProvider.setDuration(duration, curve: Curves.easeInOutBack);
    Future.delayed(duration).then((value) => configProvider.resetDuration());
  }

  void _solve() async {
    TileProvider tileProvider = context.read<TileProvider>();
    List<TilesModel> tileList = tileProvider.getTileList;
    bool isSolved = Service().isSolved(tileList);
    if (isSolved) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text("The puzzle is already solved!"),
        ));
      return;
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const AlertDialog(
            content: ListTile(
              title: Text("Trying to solve the puzzle"),
              leading: CircularProgressIndicator(),
            ),
          );
        });
    List<String> result = await Service().getSolution(tileList);
    Navigator.pop(context);
    var i = 0;
    // print("result is $result ${result.first.runtimeType} ${result.isNotEmpty}");
    if (result.isNotEmpty && result.first != "") {
      Timer.periodic(duration * 1, (timer) {
        Direction? direction;
        switch (result[i]) {
          case "Left":
            direction = Direction.left;
            break;
          case "Right":
            direction = Direction.right;
            break;
          case "Down":
            direction = Direction.down;
            break;
          case "Up":
            direction = Direction.up;
            break;
          default:
            return;
        }
        Service().moveWhite(tileList, direction);
        tileProvider.updateNotifiers();
        i++;
        if (i == result.length) timer.cancel();
      });
    }
  }

  List<Widget> buttons(double height, {bool expanded = true}) => [
        MyButton(
          label: "Shuffle",
          icon: const RiveAnimation.asset(
            'assets/rive/icons.riv',
            animations: ["shuffle"],
          ),
          expanded: expanded,
          height: height,
          onPressed: createTiles,
        ),
        // MyButton(
        //   label: "Reset",
        //   icon: const Icon(Icons.cancel),
        //   expanded: expanded,
        //   height: height,
        //   onPressed: () {},
        // ),
        MyButton(
          label: "Solve",
          icon: const RiveAnimation.asset(
            'assets/rive/icons.riv',
            animations: ["solve"],
          ),
          expanded: expanded,
          height: height,
          onPressed: _solve,
        ),
      ];

  @override
  void initState() {
    super.initState();
    AudioService.instance.init();
    controller = AnimationController(
        vsync: this, lowerBound: 0, upperBound: 1, duration: duration);
    controller.value = 1;
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      createTiles();
    });
    final isWebMobile = kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);
    if (isWebMobile) area = 0.9;
  }

  @override
  Widget build(BuildContext context) {
    int newGridSize = context.select<TileProvider, int>((_) => _.gridSize);
    // if (newGridSize != gridSize) {
    //   gridSize = newGridSize;
    //   _createTiles();
    // }
    // List<TilesModel> tileList = tileProvider.getTileList;
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   child: const Icon(Icons.add),
      //   onPressed: () {
      //     // _createTiles();
      //     var i = 0;
      //     Timer timer = Timer.periodic(duration, (timer) {
      //       Service().moveWhite(tileList, solvingMoves[i]);
      //       tileProvider.updateNotifiers();
      //       i++;
      //       if (i == solvingMoves.length) timer.cancel();
      //     });
      //     // solvingMoves.forEach((element) async {
      //     //   await Future.delayed(duration);
      //     // });
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

          double imageListMainGap = 64;
          double imageListCrossGap = 0;

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
                    padding: const EdgeInsets.all(4),
                    color: Colors.blueGrey, //.withOpacity(isTall ? 0.4 : 1),
                    height: puzzleHeight,
                    width: puzzleWidth,
                    child: const Puzzle(),
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

                AnimatedPositioned(
                  duration: duration,
                  right: isTall ? imageListMainGap : imageListCrossGap,
                  top: isTall ? null : imageListMainGap,
                  left: isTall ? imageListMainGap : null,
                  bottom: isTall ? imageListCrossGap : imageListMainGap,
                  child: ImageList(constraints: constraints, isTall: isTall),
                ),

                AnimatedPositioned(
                  duration: duration,
                  right: 16,
                  top: 4,
                  child: const ToolBar(),
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
  // void _solve() {
  //   TileProvider tileProvider = context.read<TileProvider>();
  //   List<TilesModel> tileList = tileProvider.getTileList;
  //   bool isSolved = false;
  //   int startedAt = DateTime.now().millisecondsSinceEpoch;
  //   int now = startedAt;
  //   List<Direction> moves = [];
  //   List<Direction> interMoves = [];
  //   Direction? previousMove;
  //   List<TilesModel> visitedNode = tileList
  //       .map((e) => TilesModel(
  //           defaultIndex: e.defaultIndex,
  //           currentIndex: e.currentIndex,
  //           isWhite: e.isWhite,
  //           coordinates: e.coordinates))
  //       .toList(); //List.from(tileList);
  //   Map<int, List<TilesModel>> previousNodes = {0: visitedNode};
  //   Map<int, int> h = {};

  //   // int h = -1;
  //   // tileList.forEach((e) {
  //   //   if (e.currentIndex != e.defaultIndex) h++;
  //   // });
  //   // for (var k = 0; k < 5; k++) {
  //   while (!isSolved && now - startedAt < 1000) {
  //     now = DateTime.now().millisecondsSinceEpoch;
  //     List<TilesModel> copyOfList = previousNodes[0]!
  //         .map((e) => TilesModel(
  //             defaultIndex: e.defaultIndex,
  //             currentIndex: e.currentIndex,
  //             isWhite: e.isWhite,
  //             coordinates: e.coordinates))
  //         .toList();
  //     // print("copy of list is");
  //     // copyOfList.forEach((element) {
  //     //   print(element.currentIndex + 1);
  //     // });
  //     previousNodes.clear();
  //     for (var i = 0; i < Direction.values.length; i++) {
  //       Direction thisMove = Direction.values[i];
  //       bool isParent = Service().checkIfParent(thisMove, previousMove);
  //       if (isParent) continue;
  //       List<TilesModel> copyOfCopyOfList = copyOfList
  //           .map((e) => TilesModel(
  //               defaultIndex: e.defaultIndex,
  //               currentIndex: e.currentIndex,
  //               isWhite: e.isWhite,
  //               coordinates: e.coordinates))
  //           .toList();
  //       List<TilesModel>? newList =
  //           Service().moveWhite(copyOfCopyOfList, Direction.values[i]);
  //       if (newList != null) {
  //         print("adding new list with a move of ${Direction.values[i]}");
  //         newList.forEach((element) {
  //           print(element.currentIndex + 1);
  //         });
  //         previousNodes.addAll({i: newList});
  //       }
  //     }
  //     // print(previousNodes.values.toList().first.first.coordinates);
  //     previousNodes.forEach((key, value) {
  //       h[key] = 0;
  //       value.forEach((e) {
  //         if (e.currentIndex != e.defaultIndex) {
  //           h[key] = (h[key] ?? 0) + 1;
  //         }
  //       });
  //     });
  //     var sortedKeys = h.keys.toList(growable: false)
  //       ..sort((k1, k2) => h[k1]!.compareTo(h[k2]!));
  //     LinkedHashMap sortedMap = LinkedHashMap.fromIterable(sortedKeys,
  //         key: (k) => k, value: (k) => h[k]);
  //     // print(sortedMap.keys.toList());
  //     // print(sortedMap.values.toList());
  //     int minH = sortedMap.keys.toList()[0];
  //     List<TilesModel> winningNode =
  //         previousNodes[minH] ?? previousNodes[previousNodes.keys.first]!;
  //     moves.add(Direction.values[minH]);
  //     previousMove = Direction.values[minH];
  //     previousNodes.clear();
  //     previousNodes = {0: winningNode};
  //     h.clear();
  //     isSolved = winningNode
  //         .every((element) => element.currentIndex == element.defaultIndex);
  //     // if (isSolved) {
  //     //   print("solved!!!!!!!!!!!!!!!!!!!!");
  //     //   isSolved = true;
  //     // }
  //   }
  //   print("done");
  //   print(isSolved);
  //   print(moves.toString());
  //   solvingMoves = List.from(moves);
  //   // solvingMoves.addAll(moves);
  //   tileProvider.updateNotifiers();
  // }

  // void _solve() {
  //   int level = 0;
  //   TileProvider tileProvider = context.read<TileProvider>();
  //   List<TilesModel> tileList = tileProvider.getTileList;
  //   bool isSolved = false;
  //   int startedAt = DateTime.now().millisecondsSinceEpoch;
  //   int now = startedAt;
  //   List<Direction> moves = [];
  //   List<Direction> interMoves = [];
  //   Direction? previousMove;
  //   List<TilesModel> visitedNode = tileList
  //       .map((e) => TilesModel(
  //           defaultIndex: e.defaultIndex,
  //           currentIndex: e.currentIndex,
  //           isWhite: e.isWhite,
  //           coordinates: e.coordinates))
  //       .toList(); //List.from(tileList);
  //   List<List<TilesModel>> nodes = [visitedNode];
  //   Map<int, List<TilesModel>> previousNodes = {0: visitedNode};
  //   Map<int, int> h = {};

  //   // int h = -1;
  //   // tileList.forEach((e) {
  //   //   if (e.currentIndex != e.defaultIndex) h++;
  //   // });
  //   // for (var k = 0; k < 5; k++) {
  //   while (!isSolved && now - startedAt < 1000) {
  //     now = DateTime.now().millisecondsSinceEpoch;
  //     List<TilesModel> copyOfList = previousNodes[0]!
  //         .map((e) => TilesModel(
  //             defaultIndex: e.defaultIndex,
  //             currentIndex: e.currentIndex,
  //             isWhite: e.isWhite,
  //             coordinates: e.coordinates))
  //         .toList();
  //     // print("copy of list is");
  //     // copyOfList.forEach((element) {
  //     //   print(element.currentIndex + 1);
  //     // });
  //     previousNodes.clear();
  //     level++;
  //     for (var i = 0; i < Direction.values.length; i++) {
  //       Direction thisMove = Direction.values[i];
  //       bool isParent = Service().checkIfParent(thisMove, previousMove);
  //       if (isParent) continue;
  //       List<TilesModel> copyOfCopyOfList = copyOfList
  //           .map((e) => TilesModel(
  //               defaultIndex: e.defaultIndex,
  //               currentIndex: e.currentIndex,
  //               isWhite: e.isWhite,
  //               coordinates: e.coordinates))
  //           .toList();
  //       List<TilesModel>? newList =
  //           Service().moveWhite(copyOfCopyOfList, Direction.values[i]);
  //       if (newList != null) {
  //         print("adding new list with a move of ${Direction.values[i]}");
  //         newList.forEach((element) {
  //           print(element.currentIndex + 1);
  //         });
  //         previousNodes.addAll({i: newList});
  //         nodes[level] = newList;
  //       }
  //     }
  //     // print(previousNodes.values.toList().first.first.coordinates);
  //     previousNodes.forEach((key, value) {
  //       h[key] = 0;
  //       value.forEach((e) {
  //         if (e.currentIndex != e.defaultIndex) {
  //           h[key] = (h[key] ?? 0) + 1;
  //         }
  //       });
  //     });
  //     var sortedKeys = h.keys.toList(growable: false)
  //       ..sort((k1, k2) => h[k1]!.compareTo(h[k2]!));
  //     LinkedHashMap sortedMap = LinkedHashMap.fromIterable(sortedKeys,
  //         key: (k) => k, value: (k) => h[k]);
  //     // print(sortedMap.keys.toList());
  //     // print(sortedMap.values.toList());
  //     int minH = sortedMap.keys.toList()[0];
  //     List<TilesModel> winningNode =
  //         previousNodes[minH] ?? previousNodes[previousNodes.keys.first]!;
  //     moves.add(Direction.values[minH]);
  //     previousMove = Direction.values[minH];
  //     previousNodes.clear();
  //     previousNodes = {0: winningNode};
  //     h.clear();
  //     isSolved = winningNode
  //         .every((element) => element.currentIndex == element.defaultIndex);
  //     // if (isSolved) {
  //     //   print("solved!!!!!!!!!!!!!!!!!!!!");
  //     //   isSolved = true;
  //     // }
  //   }
  //   print("done");
  //   print(isSolved);
  //   print(moves.toString());
  //   solvingMoves = List.from(moves);
  //   // solvingMoves.addAll(moves);
  //   tileProvider.updateNotifiers();
  // }
