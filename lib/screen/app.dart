import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/painting/gradient.dart' as grad;
import 'package:slide_puzzle/code/audio.dart';
import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/code/service.dart';
import 'package:slide_puzzle/screen/landing.dart';
import 'package:slide_puzzle/screen/puzzle.dart';
import 'package:slide_puzzle/ui/3d_transform.dart';
import 'package:slide_puzzle/ui/Image_list.dart';
import 'package:slide_puzzle/ui/bordered_container.dart';
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

class _LayoutPageState extends State<LayoutPage> {
  int gridSize = 4;
  Duration duration = Duration(milliseconds: defaultTime);
  Curve curve = Curves.easeOut;
  double area = 0.75;
  double offsetFromCenter = 0.5;
  bool isTopLeft = true;
  bool imageListVisibile = true;
  final isWebMobile = kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);
  final isMobile = (defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android);

  void createTiles(
      {int? gridSize, bool isChangingGrid = false, bool shuffle = true}) {
    TileProvider tileProvider = context.read<TileProvider>();
    gridSize ??= tileProvider.gridSize;
    bool isSolvable = false;
    bool isAlreadySolved = false;
    int totalTiles = pow(gridSize, 2).toInt();
    List<int> numbers = List.generate(totalTiles, (index) => index);
    List<TilesModel> list = [];
    List<int> random = List.from(numbers);
    while (!isSolvable && !isAlreadySolved) {
      if (shuffle) random.shuffle();
      list = numbers.map((e) {
        Coordinates coordinates = Coordinates(
            row: (random[e] / gridSize!).floor(), column: random[e] % gridSize);
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
      if (!shuffle) break;
    }
    ConfigProvider configProvider = context.read<ConfigProvider>();
    if (configProvider.gamestate == GameState.aiSolving) return;
    if (tileProvider.getTileList.isNotEmpty && shuffle) {
      AudioService.instance.shuffle();
      AudioService.instance.vibrate();
    }
    tileProvider.createTiles(list);
    ScoreProvider scoreProvider = context.read<ScoreProvider>();
    // scoreProvider.stopTimer();
    // scoreProvider.resetScores();
    scoreProvider.restart();
    if (shuffle) scoreProvider.beginTimer();
    var duration = Duration(milliseconds: isChangingGrid ? 0 : defaultTime * 2);
    configProvider.setDuration(duration, curve: Curves.easeInOutBack);
    if (shuffle) {
      configProvider.start();
    } else {
      configProvider.wait();
    }
    Future.delayed(isChangingGrid ? Duration(milliseconds: 10) : duration)
        .then((value) => configProvider.resetDuration());
  }

  void solve() async {
    TileProvider tileProvider = context.read<TileProvider>();
    ScoreProvider scoreProvider = context.read<ScoreProvider>();
    ConfigProvider configProvider = context.read<ConfigProvider>();
    configProvider.aiSolving();
    scoreProvider.stopTimer();
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
      Timer.periodic(duration * 0.5, (timer) {
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
        Service().moveWhite(
          tileList,
          direction,
          scoreProvider,
          configProvider,
        );
        tileProvider.updateNotifiers();
        i++;
        if (i == result.length) timer.cancel();
      });
    }
  }

  List<Widget> buttons({bool expanded = true}) => [
        MyButton(
          label: "Shuffle",
          icon: const RiveAnimation.asset(
            'assets/rive/icons.riv',
            animations: ["shuffle"],
          ),
          expanded: expanded,
          // height: height,
          onPressed: () {
            TileProvider tileProvider = context.read<TileProvider>();
            int gridSize = tileProvider.gridSize;
            createTiles(gridSize: gridSize);
          },
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
          // height: height,
          onPressed: solve,
        ),
      ];

  @override
  void initState() {
    super.initState();
    AudioService.instance.init();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      createTiles(shuffle: false);
    });
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
          double topPad = MediaQuery.of(context).padding.top;
          double puzzleHeight = isTall ? absoluteWidth : absoluteHeight;
          if (!isTall && isMobile) puzzleHeight -= topPad;
          double puzzleWidth = puzzleHeight;

          // double imageListHeight = 100;
          double imageListMainGap = isTall ? 24 : 64;
          // double imageListCrossGap = (imageListVisibile ? 0 : -90);
          double imageListCrossOffset =
              1 + (2 * 95 / (isTall ? maxHeight : maxWidth));
          double toolbarGap = isTall ? 24 : 64;

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
          double padding = 32;
          return Center(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                // image: DecorationImage(
                //     image: AssetImage("images/stripes_bg.jpg"),
                //     fit: BoxFit.cover),
                // gradient: grad.LinearGradient(colors: [
                //   primaryColor.withOpacity(0.5),
                //   primaryColor.withOpacity(0.2),
                // ]),
              ),
              // color: primaryColor.withOpacity(0.2),
              child: Stack(children: [
                AnimatedAlign(
                  duration: duration,
                  curve: curve,
                  alignment: const Alignment(0, 0),
                  // left: isTopLeft ? 20 : 0,
                  // right: !isTopLeft ? 23 : 0,
                  // top: isTopLeft ? 23 : 0,
                  // bottom: !isTopLeft ? 23 : 0,
                  child: Container(
                    height: puzzleHeight + buttonHeight,
                    width: puzzleWidth,
                    color: Colors.white,
                    child: MyTransform(
                      child: BorderedContainer(
                        label: "puzzle",
                        child: AnimatedContainer(
                          duration: duration,
                          curve: curve,
                          padding: const EdgeInsets.all(4),
                          color: secondaryColor,
                          child: Puzzle(),
                        ),
                      ),
                    ),
                  ),
                ),

                // image list
                AnimatedAlign(
                  duration: duration,
                  curve: curve,
                  alignment: isTall
                      ? imageListVisibile
                          ? Alignment.bottomCenter
                          : Alignment(0, imageListCrossOffset)
                      : imageListVisibile
                          ? Alignment.centerRight
                          : Alignment(imageListCrossOffset, 0),
                  // right: isTall ? imageListMainGap : imageListCrossGap,
                  // top: isTall ? null : imageListMainGap,
                  // left: isTall ? imageListMainGap : null,
                  // bottom: isTall ? imageListCrossGap : imageListMainGap,
                  child: Container(
                    height: isTall ? null : maxHeight - 2 * imageListMainGap,
                    width: isTall ? maxWidth - 2 * imageListMainGap : null,
                    child: ImageList(
                      constraints: constraints,
                      isTall: isTall,
                      isVisible: imageListVisibile,
                      toggleImageList: (bool visibility) =>
                          setState(() => imageListVisibile = visibility),
                    ),
                  ),
                ),

                // toolbar
                AnimatedAlign(
                  duration: duration,
                  curve: curve,
                  alignment:
                      isTall ? Alignment.topCenter : Alignment.centerLeft,
                  // left: isTall ? toolbarGap : 0,
                  // top: isTall ? topPad : toolbarGap,
                  // right: isTall ? toolbarGap : null,
                  // bottom: isTall ? null : toolbarGap,
                  child: SafeArea(
                    child: Container(
                      height: isTall ? null : maxHeight - 2 * toolbarGap,
                      width: isTall ? maxWidth - 2 * toolbarGap : null,
                      child: ToolBar(
                        constraints: constraints,
                        isTall: isTall,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}
