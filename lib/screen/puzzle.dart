import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:slide_puzzle/code/audio.dart';
import 'package:slide_puzzle/code/auth.dart';
import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/code/service.dart';
import 'package:rive/rive.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:slide_puzzle/screen/app.dart';
import 'package:slide_puzzle/ui/Scoreboard.dart';
import 'package:slide_puzzle/ui/animated_fader.dart';
import 'package:slide_puzzle/ui/button.dart';
import 'package:slide_puzzle/ui/delayed_loader.dart';
import 'package:slide_puzzle/ui/dialog.dart';
import 'package:slide_puzzle/ui/mouse_region.dart';

class Puzzle extends StatefulWidget {
  Puzzle({Key? puzzlekey}) : super(key: puzzleKey);

  @override
  _PuzzleState createState() => _PuzzleState();
}

final puzzleKey = GlobalKey<_PuzzleState>();

class _PuzzleState extends State<Puzzle> {
  // late AnimationController animationController;
  final FocusNode focusNode = FocusNode();
  int gridSize = 0;
  // late List<TilesModel> tileList;
  // late List<int> mainTiles;
  // late List<int> currentTiles;
  bool isSolved = false;
  // List<int> images = List.generate(6, (index) => index + 1);
  // int currentImage = 1;
  GameState? gameState;
  String currentVideo = "";

  void _handleKeyEvent(
    RawKeyEvent event,
    TileProvider tileProvider,
    ScoreProvider scoreProvider,
    ConfigProvider configProvider,
  ) {
    if (event.runtimeType == RawKeyDownEvent &&
        configProvider.gamestate == GameState.started) {
      var tileList = tileProvider.getTileList;
      var whiteTile = tileList.singleWhere((element) => element.isWhite);
      if (event.data.logicalKey == LogicalKeyboardKey.keyK && kDebugMode) {
        launchScoreBoard(scoreProvider, null, configProvider);
      }
      if (event.data.logicalKey == LogicalKeyboardKey.keyS) {
        _shuffle();
      }
      if (event.data.logicalKey == LogicalKeyboardKey.arrowUp) {
        Service().moveWhite(
          tileList,
          Direction.up,
          scoreProvider,
          configProvider,
        );
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        Service().moveWhite(
          tileList,
          Direction.down,
          scoreProvider,
          configProvider,
        );
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        Service().moveWhite(
          tileList,
          Direction.left,
          scoreProvider,
          configProvider,
        );
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        Service().moveWhite(
          tileList,
          Direction.right,
          scoreProvider,
          configProvider,
        );
      }
      tileProvider.updateNotifiers();
    }
  }

  _shuffle({bool shuffle = true}) {
    TileProvider tileProvider = context.read<TileProvider>();
    int gridSize = tileProvider.gridSize;
    homeKey.currentState!.createTiles(gridSize: gridSize, shuffle: shuffle);
  }

  List<Widget> buttons({bool expanded = true}) => [
        MyButton(
          label: gameState == GameState.started ? "Reset" : "Shuffle",
          tooltip: gameState == GameState.started
              ? "Reset puzzle"
              : "Shuffle the tile pieces",
          icon: RiveAnimation.asset(
            'assets/rive/icons.riv',
            animations:
                (gameState == GameState.started ? ["reset"] : ["shuffle"]),
          ),
          expanded: expanded,
          shouldAnimateEntry: gameState != GameState.started,
          isDisabled: gameState == GameState.aiSolving,
          onPressed: () {
            _shuffle(shuffle: gameState != GameState.started);
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
          tooltip: "Attempt to auto-solve the puzzle",
          icon: const RiveAnimation.asset(
            'assets/rive/icons.riv',
            animations: ["solve"],
          ),
          expanded: expanded,
          isDisabled: gameState == GameState.aiSolving,
          onPressed: homeKey.currentState!.solve,
        ),
      ];

  _checkIfSolved(List<TilesModel> tileList, ScoreProvider scoreProvider,
      ConfigProvider configProvider) async {
    UserData? userData = context.read<UserData?>();
    isSolved = Service().isSolved(tileList);
    bool aiSolved = gameState == GameState.aiSolving;
    if (isSolved &&
        tileList.isNotEmpty &&
        (gameState == GameState.started || aiSolved)) {
      if (configProvider.showNumbers) {
        await Future.delayed(const Duration(milliseconds: 200));
        scoreProvider.stopTimer();
        configProvider.finish(solvedByAI: aiSolved);
        // setState(() {
        //   gameState = GameState.finished;
        // });
        return;
      }
      UserData? newData;
      if (!aiSolved) {
        newData = await _calculateAndSubmitScore(gridSize, scoreProvider);
        AudioService.instance.success();
        launchScoreBoard(scoreProvider, newData, configProvider);
      }
      await Future.delayed(const Duration(milliseconds: 200));
      scoreProvider.stopTimer();
      configProvider.finish(solvedByAI: aiSolved);
      // setState(() {
      //   gameState = GameState.finished;
      // });
    }
  }

  _calculateAndSubmitScore(
    int gridSize,
    ScoreProvider scoreProvider,
  ) async {
    UserData? userData = context.read<UserData?>();
    // Map<String, int> score = userData!.moves;
    String grid = gridSize == 3 ? "three" : "four";
    Map<String, int> allMoves = userData!.moves;
    Map<String, int> allTimes = userData.times;
    int bestMove = allMoves[grid]!;
    int bestTime = allTimes[grid]!;
    int currentMove = scoreProvider.moves;
    int currentTime = scoreProvider.seconds;
    if (currentMove < bestMove ||
        currentTime < bestTime ||
        bestMove == 0 ||
        bestTime == 0) {
      allMoves[grid] = bestMove == 0 ? currentMove : min(bestMove, currentMove);
      allTimes[grid] = bestTime == 0 ? currentTime : min(bestTime, currentTime);
      final newData = userData.copyWith(
        uid: userData.uid,
        moves: allMoves,
        times: allTimes,
        lastSeen: Timestamp.now(),
      );
      // print(newData.toString());
      await DatabaseService.instance.updateUserData(newData);
      return newData;
    }
    return userData;
  }

  launchScoreBoard(ScoreProvider scoreProvider, UserData? newData,
      ConfigProvider configProvider,
      {bool checking = false}) async {
    await Future.delayed(Duration(milliseconds: 100));
    String grid = gridSize == 3 ? "three" : "four";
    showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.8),
        builder: (context) {
          // return AlertDialog(
          //   content: Text("asd"),
          // );
          return MyDialog(
            child: ScoreBoard(
              gridSize: gridSize,
              currentMove: (scoreProvider.moves == 0 ||
                      configProvider.gamestate == GameState.started ||
                      configProvider.solvedByAI ||
                      configProvider.showNumbers)
                  ? null
                  : scoreProvider.moves,
              currentTime: (scoreProvider.moves == 0 ||
                      configProvider.gamestate == GameState.started ||
                      configProvider.solvedByAI ||
                      configProvider.showNumbers)
                  ? null
                  : scoreProvider.seconds,
              userData: newData!,
              // bestTime: 12,
              checking: checking,
              child: const Text("Solved by AI"),
            ),
          );
        });
  }

  // _requestFocus() async {
  //   Timer.periodic(const Duration(milliseconds: 10000), (timer) {
  //     if (mounted) {
  //       setState(() {
  //         focusNode.requestFocus();
  //       });
  //     } else {
  //       timer.cancel();
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // tileList = context.read<List<TilesModel>>().reversed.toList();
    // gridSize = sqrt(tileList.length).toInt();
    // mainTiles = list.map((e) => e.defaultIndex).toList();
    // currentTiles = list.map((e) => e.currentIndex).toList();
    // mainTiles = List.generate(pow(gridSize, 2).toInt(), (index) => index);
    // currentTiles = List.from(mainTiles);
    // controller = AnimationController(vsync: this);
    // controller.repeat(period: Duration(milliseconds: defaultTime));
    // _requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    print("building puzzle");
    TileProvider tileProvider = context.watch<TileProvider>();
    ScoreProvider scoreProvider = context.read<ScoreProvider>();
    ConfigProvider configProvider = context.watch<ConfigProvider>();
    List<TilesModel> tileList = tileProvider.getTileList;
    gridSize = sqrt(tileList.length).toInt();
    gameState = configProvider.gamestate;
    bool aiSolving = gameState == GameState.aiSolving;
    _checkIfSolved(tileList, scoreProvider, configProvider);
    // list.forEach((e) {
    //   bool solved = true;
    //   if (e.currentIndex != e.defaultIndex) {
    //     isSolved = false;
    //   }
    // });
    // list.reversed;
    focusNode.requestFocus();
    AssetImage assetImage = //AssetImage("assets/images/coffee.gif");
        AssetImage(tileProvider.images[tileProvider.currentImage]);

    // LottieBuilder image = Lottie.asset(
    //   tileProvider.images[tileProvider.currentImage],
    //   repeat: true,
    //   frameRate: FrameRate(20),
    //   controller: controller,
    //   onLoaded: (comp) {
    //     controller.repeat(period: comp.duration);
    //   },
    //   fit: BoxFit.cover,
    //   alignment: Alignment.center,
    //   height: double.minPositive, //double.minPositive,
    //   width: double.minPositive, //double.minPositive,
    // );
    Image image = Image(
      image: assetImage,
      // "images/simple_dash_large.png",
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      height: double.minPositive, //double.minPositive,
      width: double.minPositive, //double.minPositive,
    );
    // Widget image = Container(
    //     height: double.minPositive, //double.minPositive,
    //     width: double.minPositive, //double.minPositive,
    //     child: const RiveAnimation.asset(
    //       'assets/rive/walk.riv',
    //       animations: ["walk"],
    //     ));
    // AssetImage assetImage =
    //     const AssetImage("images/simple_dash_large_opaque.png");

    return RawKeyboardListener(
      autofocus: true,
      focusNode: focusNode,
      onKey: (RawKeyEvent event) {
        _handleKeyEvent(event, tileProvider, scoreProvider, configProvider);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          var thisConstraints = BoxConstraints(
              maxHeight: constraints.maxHeight - (aiSolving ? 0 : buttonHeight),
              maxWidth: constraints.maxWidth);
          return Stack(
            children: [
              for (var i = 0; i < tileList.length; i++) ...{
                PuzzleTile(
                  tileList: tileList,
                  constraints: thisConstraints,
                  gridSize: gridSize,
                  currentIndex: tileList[i].currentIndex,
                  defaultIndex: tileList[i].defaultIndex,
                  isWhite: tileList[i].isWhite,
                  image: image,
                  onTap: (int newPos) {
                    // list.shuffle();
                    // setState(() {
                    //   currentTiles.shuffle();
                    // });
                    // final temp = list[0].currentIndex;
                    // list[0].currentIndex = list[1].currentIndex;
                    // list[1].currentIndex = temp;
                    // setState(() {});
                  },
                ),
              },
              AnimatedSwitcher(
                duration: configProvider.duration,
                switchInCurve: configProvider.curve,
                child: aiSolving
                    ? Container()
                    : DelayedLoader(
                        configProvider: configProvider,
                        label: "Buttons",
                        duration: const Duration(milliseconds: 2000),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            children: buttons(expanded: true),
                          ),
                        ),
                      ),
              ),
              AnimatedSwitcher(
                duration: configProvider.duration,
                switchInCurve: configProvider.curve,
                child: configProvider.processing
                    ? SizedBox.expand(
                        child: Container(
                          color: Colors.black.withOpacity(0.9),
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AutoSizeText(
                                "Processing",
                                maxLines: 1,
                                minFontSize: 8,
                              ),
                              MyButton(
                                label: "Cancel",
                                labelStyle: TextStyle(fontSize: 12),
                                onPressed: () {
                                  homeKey.currentState!.cancelableOperation
                                      .cancel();
                                },
                                expanded: false,
                                tooltip: "Abort solving the puzzle",
                                shouldAnimateEntry: false,
                              )
                            ],
                          )),
                        ),
                      )
                    : Container(),
              )
              // ElevatedButton(
              //     onPressed: () {
              //       tileProvider.changeImage(Random().nextInt(6) + 1);
              //     },
              //     child: const Text("change image"))
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    focusNode.dispose();
    // controller.dispose();
    super.dispose();
  }
}

class PuzzleTile extends StatefulWidget {
  final List<TilesModel> tileList;
  final int gridSize;
  final int currentIndex;
  final int defaultIndex;
  final BoxConstraints constraints;
  final bool isWhite;
  final Function(int newPos) onTap;
  final Widget image;
  PuzzleTile({
    Key? key,
    required this.tileList,
    required this.gridSize,
    required this.currentIndex,
    required this.constraints,
    required this.defaultIndex,
    required this.isWhite,
    required this.onTap,
    required this.image,
  }) : super(key: key);

  @override
  State<PuzzleTile> createState() => _PuzzleTileState();
}

class _PuzzleTileState extends State<PuzzleTile> with TickerProviderStateMixin {
  late AnimationController animationController;
  // Duration defaultDuration = const Duration(milliseconds: 1200);
  // Duration duration = const Duration(milliseconds: 1200);

  // Curve curve = Curves.easeOutBack;

  // double? tweenLeftOffset;
  // double? tweenTopOffset;
  double? mouseOffset;
  bool isAnimating = true;
  bool isHovering = false;
  Size? _size;

  _onPanEnd(
    DragEndDetails details,
    bool isSameRow,
    bool isSameColumn,
    bool isWhiteOnRightBelow,
    TweenProvider tweenProvider,
    TileProvider tileProvider,
    ConfigProvider configProvider,
    ScoreProvider scoreProvider,
    TilesModel thisTile,
    TilesModel whiteTile,
    double tileSize,
  ) {
    // print("pan end");
    double velocity = isSameRow
        ? details.velocity.pixelsPerSecond.dx
        : details.velocity.pixelsPerSecond.dy;
    if (((velocity < 0 && !isWhiteOnRightBelow) ||
            (tweenProvider.tweenLeftOffset ?? 0).abs() > tileSize / 2) ||
        ((velocity > 0 && isWhiteOnRightBelow) ||
            (tweenProvider.tweenTopOffset ?? 0).abs() > tileSize / 2)) {
      if (isSameRow || isSameColumn) {
        Service().changePosition(
            widget.tileList, thisTile, whiteTile, scoreProvider, configProvider,
            gridSize: isSameColumn ? widget.gridSize : 1);
        tileProvider.updateNotifiers();
      }
    } else {
      // AudioService.instance.drag(failed: true);
      AudioService.instance.vibrate();
    }
    mouseOffset = null;
    tweenProvider.setData();
    configProvider.resetDuration();
    setState(() {});
    // AudioService.instance.drag(starting: false);
  }

  _onPanUpdate(
    DragUpdateDetails details,
    bool isSameRow,
    bool isSameColumn,
    double tileSize,
    bool isWhiteOnRightBelow,
    TweenProvider tweenProvider,
    int row,
    int column,
  ) {
    if (isSameRow || isSameColumn) {
      double newOffset =
          (isSameRow ? details.localPosition.dx : details.localPosition.dy) -
              (mouseOffset ?? 0);
      if ((newOffset > 0 && newOffset < tileSize && isWhiteOnRightBelow) ||
          (newOffset < 0 && newOffset > -tileSize && !isWhiteOnRightBelow)) {
        setState(() {
          if (isSameRow) {
            tweenProvider.setData(
                tweenLeftOffset: newOffset, userColumn: column);
          }
          if (isSameColumn) {
            tweenProvider.setData(tweenTopOffset: newOffset, userRow: row);
          }
        });
      }
    }
  }

  _animateEntry() {
    ConfigProvider configProvider = context.read<ConfigProvider>();
    String name = "puzzleTile${widget.defaultIndex}";
    // if (configProvider.entryAnimationDone[name] != null &&
    //     configProvider.entryAnimationDone[name]!) {
    //   isAnimating = false;
    //   return;
    // }
    if (!_ifAnimated()) {
      configProvider.seenEntryAnimation(name);
      if (widget.currentIndex == 0) AudioService.instance.tiles();
      animationController.forward().then((value) => isAnimating = false);
    }
  }

  bool _ifAnimated() {
    ConfigProvider configProvider = context.read<ConfigProvider>();
    String name = "puzzleTile${widget.defaultIndex}";
    if (configProvider.entryAnimationDone[name] != null &&
        configProvider.entryAnimationDone[name]!) {
      isAnimating = false;
      animationController.value = 1;
      return true;
    }
    return false;
  }

  _makeEmReanimate() {
    ConfigProvider configProvider = context.read<ConfigProvider>();
    String name = "puzzleTile${widget.defaultIndex}";
    configProvider.entryAnimationDone[name] = false;
    isAnimating = true;
  }

  reverseAnim(TileProvider tileProvider) {
    if (widget.currentIndex == 0) AudioService.instance.tilesExit();
    animationController.reverse().then((value) {
      _makeEmReanimate();
      if (widget.currentIndex == 0) {
        int index = tileProvider.gridSize;
        tileProvider.changeGridSize(index == 3 ? 4 : 3);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    // _animateEntry();
    _ifAnimated();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print("building tile");
    TileProvider tileProvider = context.read<TileProvider>();
    if (tileProvider.reverse) {
      reverseAnim(tileProvider);
    }
    TweenProvider tweenProvider = context.read<TweenProvider>();
    ConfigProvider configProvider = context.read<ConfigProvider>();
    ScoreProvider scoreProvider = context.read<ScoreProvider>();

    Size size = widget.constraints.biggest;
    _size ??= size;
    Duration duration = size != _size ? Duration.zero : configProvider.duration;
    _size = size;

    double maxHeight = widget.constraints.maxHeight;
    TilesModel thisTile = widget.tileList.firstWhere(
      (element) => element.currentIndex == widget.currentIndex,
      orElse: () => TilesModel(
          defaultIndex: 0,
          currentIndex: 0,
          isWhite: true,
          coordinates: Coordinates(row: 0, column: 0)),
    );
    TilesModel whiteTile =
        widget.tileList.firstWhere((element) => element.isWhite);
    int row = thisTile.coordinates.row;
    int column =
        thisTile.coordinates.column; //(currentIndex.remainder(gridSize));
    int whiteIndex = whiteTile.currentIndex;
    int whiteRow = whiteTile.coordinates.row;
    int whiteColumn =
        whiteTile.coordinates.column; //(whiteIndex.remainder(gridSize));
    bool isSameRow = row == whiteRow;
    bool isSameColumn = column == whiteColumn;
    bool isWhiteOnRightBelow = widget.currentIndex - whiteIndex < 0;
    bool isTop = row == 0;
    bool isLeft = column == 0;
    bool isBottom = row == widget.gridSize - 1;
    bool isRight = column == widget.gridSize - 1;
    double gap = thisTile.currentIndex == thisTile.defaultIndex ? 0 : 1;
    double totalGap = ((widget.gridSize + 1) * gap);
    double height = (maxHeight - totalGap) / widget.gridSize;

    double leftMousePos = 0;
    double topMousePos = 0;
    if (isSameRow) {
      if ((widget.currentIndex < whiteIndex &&
              (tweenProvider.userColumn ?? 0) <= column ||
          (widget.currentIndex > whiteIndex &&
              (tweenProvider.userColumn ?? 0) >= column))) {
        leftMousePos = tweenProvider.tweenLeftOffset ?? 0;
      }
    } else if (isSameColumn) {
      if ((widget.currentIndex < whiteIndex &&
              (tweenProvider.userRow ?? 0) <= row ||
          (widget.currentIndex > whiteIndex &&
              (tweenProvider.userRow ?? 0) >= row))) {
        topMousePos = tweenProvider.tweenTopOffset ?? 0;
      }
    }

    double topOffset = (maxHeight * row) / widget.gridSize + topMousePos;
    double leftOffset = (maxHeight * column) / widget.gridSize + leftMousePos;
    // if (isHovering) {
    //   height += 4;
    //   topOffset -= 2;
    //   leftOffset -= 2;
    // }
    double tileSize = height + gap;
    //row: (random[e] / gridSize).floor(), column: random[e] % gridSize
    int defaultRow = (thisTile.defaultIndex / widget.gridSize).floor();
    int defaultColumn = thisTile.defaultIndex % widget.gridSize;
    double imageTop = -0.5 +
        (1 *
            defaultRow /
            (widget.gridSize -
                1)); // replace with -1 + (2 * ...) for alignment calculations
    // print(
    //     "default coords of ${thisTile.defaultIndex} is $defaultRow, $defaultColumn");
    // print(2 * defaultRow / (widget.gridSize - 1));
    // print(imageTop);
    double imageLeft = -0.5 + (1 * defaultColumn / (widget.gridSize - 1));
    Offset finalImageOffset = //(isTop || isBottom || isLeft || isRight)
        Offset(height * imageLeft, height * imageTop);
    // : Offset(
    //     height * imageLeft,
    //     height *
    //         imageTop); //Offset(height * imageLeft - gap, height * imageTop - gap);
    Widget tileContainer = MyAnimatedFader(
        isVisible: !widget.isWhite ||
            (configProvider.gamestate == GameState.waiting ||
                configProvider.gamestate == GameState.finished),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 100),
              // alignment: Alignment.center,
              height: height,
              width: height,
              // decoration: isHovering
              //     ? BoxDecoration(border: Border.all(color: primaryColor))
              //     : const BoxDecoration(),
              child: ClipRect(
                child: OverflowBox(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  // alignment: Alignment.topLeft,
                  child: Transform.scale(
                    scale: widget.gridSize.toDouble().toDouble(),
                    origin: finalImageOffset,
                    // alignment: Alignment(imageLeft, imageTop),
                    child: widget.image,
                  ),
                ),
              ),
            ),
            configProvider.showNumbers
                ? Center(
                    child: AutoSizeText(
                    "${widget.defaultIndex + 1}",
                    style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black, blurRadius: 1)]),
                  ))
                : Container()
          ],
        ));
    return AnimatedPositioned(
      duration: duration,
      curve: configProvider.curve,
      top: topOffset + gap / 2,
      left: leftOffset + gap / 2,
      child: MyMouseRegion(
        configProvider: configProvider,
        thisTile: thisTile,
        child: GestureDetector(
          onPanUpdate: (details) {
            if (configProvider.gamestate == GameState.started) {
              _onPanUpdate(details, isSameRow, isSameColumn, tileSize,
                  isWhiteOnRightBelow, tweenProvider, row, column);
            }
          },
          onPanDown: (details) {
            mouseOffset = (isSameRow
                ? details.localPosition.dx
                : isSameColumn
                    ? details.localPosition.dy
                    : null);
          },
          onPanStart: (_) {
            if (configProvider.gamestate == GameState.started) {
              configProvider.setDuration(const Duration(milliseconds: 0));
              // AudioService.instance.drag();
              AudioService.instance.vibrate();
            }
          },
          onPanEnd: (details) {
            if (configProvider.gamestate == GameState.started) {
              _onPanEnd(
                  details,
                  isSameRow,
                  isSameColumn,
                  isWhiteOnRightBelow,
                  tweenProvider,
                  tileProvider,
                  configProvider,
                  scoreProvider,
                  thisTile,
                  whiteTile,
                  tileSize);
            }
          },
          // onPanCancel: () {
          // print("pan cancel");
          // mouseOffset = null;
          // },
          onTap:
              thisTile.isWhite || configProvider.gamestate != GameState.started
                  ? null
                  : () {
                      if (isSameRow || isSameColumn) {
                        Service().changePosition(
                          widget.tileList,
                          thisTile,
                          whiteTile,
                          scoreProvider,
                          configProvider,
                          gridSize: isSameColumn ? widget.gridSize : 1,
                        );
                        tileProvider.updateNotifiers();
                      }
                    },
          child: isAnimating
              ? FutureBuilder(
                  future: Future.delayed(Duration(
                      milliseconds:
                          defaultEntryTime + widget.defaultIndex * 50)),
                  builder: (context, snapshot) {
                    bool isDone =
                        snapshot.connectionState == ConnectionState.done;
                    if (isDone) {
                      _animateEntry();
                    }
                    return Opacity(
                      opacity: isDone ? 1 : 0.01,
                      child: ScaleTransition(
                          scale: CurvedAnimation(
                              parent: animationController,
                              curve: Curves.easeOutBack),
                          child: tileContainer),
                    );
                  })
              : ScaleTransition(
                  scale: CurvedAnimation(
                      parent: animationController, curve: Curves.easeOutBack),
                  child: tileContainer),
        ),
      ),
    );
  }
}
