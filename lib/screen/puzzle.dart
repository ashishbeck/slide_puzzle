import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/code/service.dart';
import 'package:slide_puzzle/ui/custom_positioned.dart';

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

  void _handleKeyEvent(RawKeyEvent event, TileProvider tileProvider) {
    if (event.runtimeType == RawKeyDownEvent) {
      var tileList = tileProvider.getTileList;
      var whiteTile = tileList.singleWhere((element) => element.isWhite);
      if (event.data.logicalKey == LogicalKeyboardKey.arrowUp) {
        Service().moveWhite(tileList, Direction.up);
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        Service().moveWhite(tileList, Direction.down);
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        Service().moveWhite(tileList, Direction.left);
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        Service().moveWhite(tileList, Direction.right);
      }
      tileProvider.updateNotifiers();
    }
  }

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
    List<TilesModel> tileList = context.watch<TileProvider>().getTileList;
    gridSize = sqrt(tileList.length).toInt();
    isSolved = Service().isSolved(tileList);
    if (isSolved && tileList.isNotEmpty) {
      print("Solved!!");
    }
    // list.forEach((e) {
    //   bool solved = true;
    //   if (e.currentIndex != e.defaultIndex) {
    //     isSolved = false;
    //   }
    // });
    // list.reversed;
    _focusNode.requestFocus();
    return RawKeyboardListener(
      autofocus: true,
      focusNode: _focusNode,
      onKey: (RawKeyEvent event) {
        _handleKeyEvent(event, tileProvider);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              for (var i = 0; i < tileList.length; i++) ...{
                PuzzleTile(
                  tileList: tileList,
                  constraints: constraints,
                  gridSize: gridSize,
                  currentIndex: tileList[i].currentIndex,
                  defaultIndex: tileList[i].defaultIndex,
                  isWhite: tileList[i].isWhite,
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
                )
              },
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
  PuzzleTile({
    Key? key,
    required this.tileList,
    required this.gridSize,
    required this.currentIndex,
    required this.constraints,
    required this.defaultIndex,
    required this.isWhite,
    required this.onTap,
  }) : super(key: key);

  @override
  State<PuzzleTile> createState() => _PuzzleTileState();
}

class _PuzzleTileState extends State<PuzzleTile> {
  // Duration defaultDuration = const Duration(milliseconds: 1200);
  // Duration duration = const Duration(milliseconds: 1200);

  // Curve curve = Curves.easeOutBack;

  // double? tweenLeftOffset;
  // double? tweenTopOffset;
  double? mouseOffset;

  _onPanEnd(
    DragEndDetails details,
    bool isSameRow,
    bool isSameColumn,
    bool isWhiteOnRightBelow,
    TweenProvider tweenProvider,
    TileProvider tileProvider,
    ConfigProvider configProvider,
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
        Service().changePosition(widget.tileList, thisTile, whiteTile,
            gridSize: isSameColumn ? widget.gridSize : 1);
        tileProvider.updateNotifiers();
      }
    }
    mouseOffset = null;
    tweenProvider.setData();
    configProvider.resetDuration();
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    TileProvider tileProvider = context.watch<TileProvider>();
    TweenProvider tweenProvider = context.watch<TweenProvider>();
    ConfigProvider configProvider = context.watch<ConfigProvider>();
    double maxHeight = widget.constraints.maxHeight;
    TilesModel thisTile = widget.tileList
        .firstWhere((element) => element.currentIndex == widget.currentIndex);
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
    // bool isTop = row == 0;
    // bool isLeft = column == 0;
    // bool isBottom = row == gridSize - 1;
    // bool isRight = column == gridSize - 1;
    double gap = 2;
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
    Widget container = widget.isWhite
        ? Container()
        : Container(
            height: height,
            width: height,
            color: widget.isWhite ? Colors.white.withOpacity(0.2) : Colors.red,
            child: Center(child: Text("(${widget.defaultIndex + 1})")),
          );
    return AnimatedPositioned(
      duration: configProvider.duration,
      curve: configProvider.curve,
      top: topOffset + gap / 2,
      left: leftOffset + gap / 2,
      child: MouseRegion(
        cursor: thisTile.isWhite
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        child: GestureDetector(
          onPanUpdate: (details) {
            _onPanUpdate(details, isSameRow, isSameColumn, tileSize,
                isWhiteOnRightBelow, tweenProvider, row, column);
          },
          onPanDown: (details) {
            mouseOffset = (isSameRow
                ? details.localPosition.dx
                : isSameColumn
                    ? details.localPosition.dy
                    : null);
          },
          onPanStart: (_) =>
              configProvider.setDuration(const Duration(milliseconds: 0)),
          onPanEnd: (details) {
            _onPanEnd(
                details,
                isSameRow,
                isSameColumn,
                isWhiteOnRightBelow,
                tweenProvider,
                tileProvider,
                configProvider,
                thisTile,
                whiteTile,
                tileSize);
          },
          // onPanCancel: () {
          // print("pan cancel");
          // mouseOffset = null;
          // },
          onTap: thisTile.isWhite
              ? null
              : () {
                  if (isSameRow || isSameColumn) {
                    Service().changePosition(
                      widget.tileList,
                      thisTile,
                      whiteTile,
                      gridSize: isSameColumn ? widget.gridSize : 1,
                    );
                    tileProvider.updateNotifiers();
                  }
                },
          child: container,
        ),
      ),
    );
  }
}
