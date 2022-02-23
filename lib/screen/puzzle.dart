import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:slide_puzzle/code/audio.dart';
import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/code/service.dart';
import 'package:rive/rive.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:slide_puzzle/screen/app.dart';
import 'package:slide_puzzle/ui/button.dart';
import 'package:slide_puzzle/ui/delayed_loader.dart';

class Puzzle extends StatefulWidget {
  const Puzzle({Key? key}) : super(key: key);

  @override
  _PuzzleState createState() => _PuzzleState();
}

class _PuzzleState extends State<Puzzle> {
  final FocusNode _focusNode = FocusNode();
  int gridSize = 0;
  // late List<TilesModel> tileList;
  // late List<int> mainTiles;
  // late List<int> currentTiles;
  bool isSolved = false;
  List<int> images = List.generate(6, (index) => index + 1);
  int currentImage = 1;

  void _handleKeyEvent(
    RawKeyEvent event,
    TileProvider tileProvider,
    ScoreProvider scoreProvider,
  ) {
    if (event.runtimeType == RawKeyDownEvent) {
      var tileList = tileProvider.getTileList;
      var whiteTile = tileList.singleWhere((element) => element.isWhite);
      if (event.data.logicalKey == LogicalKeyboardKey.arrowUp) {
        Service().moveWhite(tileList, Direction.up, scoreProvider);
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        Service().moveWhite(tileList, Direction.down, scoreProvider);
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        Service().moveWhite(tileList, Direction.left, scoreProvider);
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        Service().moveWhite(tileList, Direction.right, scoreProvider);
      }
      tileProvider.updateNotifiers();
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
          onPressed: () {
            TileProvider tileProvider = context.read<TileProvider>();
            int gridSize = tileProvider.gridSize;
            homeKey.currentState!.createTiles(gridSize: gridSize);
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
          onPressed: homeKey.currentState!.solve,
        ),
      ];

  @override
  void initState() {
    super.initState();
    // tileList = context.read<List<TilesModel>>().reversed.toList();
    // gridSize = sqrt(tileList.length).toInt();
    // mainTiles = list.map((e) => e.defaultIndex).toList();
    // currentTiles = list.map((e) => e.currentIndex).toList();
    // mainTiles = List.generate(pow(gridSize, 2).toInt(), (index) => index);
    // currentTiles = List.from(mainTiles);
  }

  @override
  Widget build(BuildContext context) {
    TileProvider tileProvider = context.watch<TileProvider>();
    ScoreProvider scoreProvider = context.read<ScoreProvider>();
    ConfigProvider configProvider = context.read<ConfigProvider>();
    List<TilesModel> tileList = tileProvider.getTileList;
    gridSize = sqrt(tileList.length).toInt();
    isSolved = Service().isSolved(tileList);
    if (isSolved &&
        tileList.isNotEmpty &&
        configProvider.gamestate == GameState.started) {
      print("Solved!!");
      scoreProvider.stopTimer();
      configProvider.finish();
    }
    // list.forEach((e) {
    //   bool solved = true;
    //   if (e.currentIndex != e.defaultIndex) {
    //     isSolved = false;
    //   }
    // });
    // list.reversed;
    _focusNode.requestFocus();
    AssetImage assetImage =
        AssetImage("assets/images/pexels_${tileProvider.currentImage}.jpg");
    Image image = Image(
      image: assetImage,
      // "images/simple_dash_large.png",
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      height: double.minPositive, //double.minPositive,
      width: double.minPositive, //double.minPositive,
    );
    // Widget rive = Container(
    //     height: double.minPositive, //double.minPositive,
    //     width: double.minPositive, //double.minPositive,
    //     child: const RiveAnimation.asset(
    //       'assets/rive/icons.riv',
    //       animations: ["shuffle"],
    //     ));
    // AssetImage assetImage =
    //     const AssetImage("images/simple_dash_large_opaque.png");

    return RawKeyboardListener(
      autofocus: true,
      focusNode: _focusNode,
      onKey: (RawKeyEvent event) {
        _handleKeyEvent(event, tileProvider, scoreProvider);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          var thisConstraints = BoxConstraints(
              maxHeight: constraints.maxHeight - buttonHeight,
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
              DelayedLoader(
                configProvider: configProvider,
                label: "Buttons",
                duration: Duration(milliseconds: 2000),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    children: buttons(expanded: true),
                  ),
                ),
              ),
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
    _focusNode.dispose();
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
  PuzzleTile(
      {Key? key,
      required this.tileList,
      required this.gridSize,
      required this.currentIndex,
      required this.constraints,
      required this.defaultIndex,
      required this.isWhite,
      required this.onTap,
      required this.image})
      : super(key: key);

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
            widget.tileList, thisTile, whiteTile, scoreProvider,
            gridSize: isSameColumn ? widget.gridSize : 1);
        tileProvider.updateNotifiers();
      }
    } else {
      AudioService.instance.drag(failed: true);
      AudioService.instance.vibrate();
    }
    mouseOffset = null;
    tweenProvider.setData();
    configProvider.resetDuration();
    setState(() {});
    AudioService.instance.drag(starting: false);
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
      animationController.forward().then((value) => isAnimating = false);
    }
  }

  bool _ifAnimated() {
    ConfigProvider configProvider = context.read<ConfigProvider>();
    String name = "puzzleTile${widget.defaultIndex}";
    if (configProvider.entryAnimationDone[name] != null &&
        configProvider.entryAnimationDone[name]!) {
      isAnimating = false;
      return true;
    }
    return false;
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
    TileProvider tileProvider = context.watch<TileProvider>();
    TweenProvider tweenProvider = context.watch<TweenProvider>();
    ConfigProvider configProvider = context.watch<ConfigProvider>();
    ScoreProvider scoreProvider = context.read<ScoreProvider>();
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
    double gap = 1;
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
    Widget container = widget.isWhite
        ? Container()
        : Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: height,
                width: height,
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
                          shadows: [
                            Shadow(color: Colors.black, blurRadius: 1)
                          ]),
                    ))
                  : Container()
            ],
          );
    return AnimatedPositioned(
      duration: configProvider.duration,
      curve: configProvider.curve,
      top: topOffset + gap / 2,
      left: leftOffset + gap / 2,
      child: MouseRegion(
        cursor: configProvider.gamestate == GameState.started
            ? thisTile.isWhite
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
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
            configProvider.setDuration(const Duration(milliseconds: 0));
            AudioService.instance.drag();
            AudioService.instance.vibrate();
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
                          child: container),
                    );
                  })
              : container,
        ),
      ),
    );
  }
}
