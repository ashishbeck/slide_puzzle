import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:slide_puzzle/code/audio.dart';
import 'package:slide_puzzle/ui/spinner.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:slide_puzzle/code/auth.dart';
import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/code/service.dart';
import 'package:slide_puzzle/ui/button.dart';

class ScoreBoard extends StatefulWidget {
  final Widget child;
  final int gridSize;
  final int? currentMove;
  final int? currentTime;
  final UserData userData;
  final bool checking;
  const ScoreBoard({
    Key? key,
    required this.child,
    required this.gridSize,
    this.currentMove,
    this.currentTime,
    required this.userData,
    this.checking = false,
  }) : super(key: key);

  @override
  _ScoreBoardState createState() => _ScoreBoardState();
}

class _ScoreBoardState extends State<ScoreBoard>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final ItemScrollController itemScrollController = ItemScrollController();
  late Future<CommunityScores> future;
  int gridSize = 0;
  Map<String, int> addExtraData = {"three": 0, "four": 0};
  bool animateToMe = true;

  void _scrollToMe(int myPosition) async {
    await Future.delayed(const Duration(milliseconds: 500));
    itemScrollController.scrollTo(
        index: myPosition,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutQuad);
    animateToMe = false;
  }

  @override
  void initState() {
    super.initState();
    gridSize = widget.gridSize;
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    controller.repeat(reverse: true);
    // DatabaseService.instance.fetchCommunityScores();
    future = DatabaseService.instance.fetchCommunityScores();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String grid = gridSize == 3 ? "three" : "four";
    double maxHeight = MediaQuery.of(context).size.height;
    double maxWidth = MediaQuery.of(context).size.width;
    bool isTall = maxHeight > maxWidth;
    double area = 0.8;
    double height = isTall ? maxWidth * 0.8 : maxHeight * 0.8;
    String movesPercentile = "";
    String timesPercentile = "";
    int rank = 0;
    UserData userData = widget.userData;

    // final List<ChartData> chartData = [
    //   ChartData(7, 0),
    //   ChartData(8, 5),
    //   ChartData(9, 14),
    //   ChartData(10, 35),
    //   ChartData(11, 42),
    //   ChartData(12, 56),
    //   ChartData(13, 76),
    //   ChartData(14, 97),
    //   ChartData(15, 124),
    //   ChartData(16, 159),
    //   ChartData(17, 146),
    //   ChartData(18, 124),
    //   ChartData(19, 97),
    //   ChartData(20, 76),
    //   ChartData(21, 56),
    //   ChartData(22, 34),
    //   ChartData(23, 19),
    //   ChartData(24, 0),
    // ];

    Widget chart(
      bool isDone,
      List<ChartData> chartData, {
      required int? current,
      required int best,
      required bool isTime,
    }) {
      // if (originalChartData[grid]!.isEmpty) {
      //   originalChartData[grid] = List.from(chartData);
      // }
      if (isTime) {
        double timesPercentileData =
            (Service().calculatePercentile(chartData, current ?? (best)));
        timesPercentile = timesPercentileData.toInt() == timesPercentileData
            ? timesPercentileData.toInt().toString()
            : timesPercentileData.toStringAsFixed(2);
      } else {
        double movesPercentileData =
            Service().calculatePercentile(chartData, current ?? (best));
        movesPercentile = movesPercentileData.toInt() == movesPercentileData
            ? movesPercentileData.toInt().toString()
            : movesPercentileData.toStringAsFixed(2);
      }

      String title = best == 0 && (current == 0 || current == null)
          ? "You need to play at least once to see how you stack against others"
          : isTime
              ? "You solved the puzzle faster than $timesPercentile% of people"
              : "You solved the puzzle in fewer steps than $movesPercentile% of people";
      String annotationText(score) =>
          isTime ? Service().intToTimeLeft(score) : "$score moves";

      Animation<Offset> position =
          Tween<Offset>(begin: Offset(0, -0.20), end: Offset(0, -0.45))
              .animate(controller);

      CartesianChartAnnotation dummyAnnotation = CartesianChartAnnotation(
        widget: Container(),
        coordinateUnit: CoordinateUnit.point,
        region: AnnotationRegion.chart,
        x: 0,
        y: 0,
      );

      var bestY = 0;
      var currentY = 0;
      try {
        bestY = (isDone ? chartData.firstWhere((e) => e.x == best).y : 35);
      } catch (e) {
        if (best != 0) chartData.add(ChartData(best, 1));
        bestY = 1;
      }
      try {
        currentY =
            (isDone ? chartData.firstWhere((e) => e.x == current).y : 35);
      } catch (e) {
        if (current != null) {
          chartData.add(ChartData(current, 1));
          currentY = 1;
        }
      }
      chartData.sort(
        (a, b) => a.x.compareTo(b.x),
      );
      if (addExtraData[grid]! < 2) {
        var total = chartData.last.x - chartData.first.x;
        chartData.insert(
            0, ChartData((chartData.first.x - 0.1 * total).toInt(), 0));
        chartData.add(ChartData((chartData.last.x + 0.1 * total).toInt(), 0));
        addExtraData[grid] = addExtraData[grid]! + 1;
      }
      // chartData.sort(
      //   (a, b) => a.x.compareTo(b.x),
      // );

      return SfCartesianChart(
        title: ChartTitle(
            text: title,
            textStyle: Theme.of(context)
                .textTheme
                .subtitle2!
                .copyWith(fontFamily: "Glacial")),
        primaryYAxis: NumericAxis(isVisible: false),
        primaryXAxis: isTime
            ? NumericAxis(
                majorGridLines: const MajorGridLines(width: 0),
                title: AxisTitle(text: isTime ? "time" : "moves"),
                axisLabelFormatter: (details) {
                  int time = int.parse(details.text);
                  time = time < 0 ? 0 : time;
                  String text = Service().intToTimeLeft(time);
                  return ChartAxisLabel(text, const TextStyle(fontSize: 12));
                })
            : NumericAxis(
                majorGridLines: const MajorGridLines(width: 0),
                title: AxisTitle(text: isTime ? "time" : "moves"),
              ),
        plotAreaBackgroundColor: Colors.black26,
        series: <ChartSeries>[
          // SplineAreaSeries<ChartData, int>(
          //   dataSource: isDone ? chartData : [],
          //   xValueMapper: (ChartData sales, _) => sales.x,
          //   yValueMapper: (ChartData sales, _) => sales.y,
          //   animationDuration: 1,
          //   borderColor: primaryColor,
          //   gradient: LinearGradient(
          //     colors: [
          //       primaryColor,
          //       Colors.transparent,
          //     ],
          //     begin: Alignment.topCenter,
          //     end: Alignment.bottomCenter,
          //   ),
          // ),
          SplineSeries<ChartData, int>(
            dataSource: isDone ? chartData : [],
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y,
            color: Colors.white,
          ),
        ],
        // onMarkerRender: (MarkerRenderArgs markerargs) {
        //   if (markerargs.pointIndex == 12) {
        //     markerargs.markerHeight = 20.0;
        //     markerargs.markerWidth = 20.0;
        //     markerargs.shape = DataMarkerType.triangle;
        //   }
        // },
        annotations: [
          // CartesianChartAnnotation(
          //   widget: Container(
          //       child: Text(
          //     'You solved the puzzle faster than x% of people',
          //     style: Theme.of(context)
          //         .textTheme
          //         .subtitle2!
          //         .copyWith(fontFamily: "Glacial"),
          //   )),
          //   coordinateUnit: CoordinateUnit.point,
          //   region: AnnotationRegion.plotArea,
          //   x: 11,
          //   y: 56 + 8,
          // ),
          current != null && current != best
              ? CartesianChartAnnotation(
                  widget: Container(
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -12,
                          child: Text(
                            annotationText(current),
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        SlideTransition(
                            position: position,
                            child: const Icon(Icons.keyboard_arrow_down)),
                        const SizedBox(
                          height: 36,
                        )
                      ],
                    ),
                  ),
                  coordinateUnit: CoordinateUnit.point,
                  region: AnnotationRegion.chart,
                  x: current + 0,
                  y: currentY + 2)
              : dummyAnnotation,
          best != 0
              ? CartesianChartAnnotation(
                  widget: Container(
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -28,
                          child: Text(
                            current != best
                                ? "your best\n(${annotationText(best)})"
                                : "new best!\n(${annotationText(best)})",
                            style: TextStyle(color: primaryColor, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SlideTransition(
                            position: position,
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: primaryColor,
                            )),
                        SizedBox(
                          height: 36,
                        )
                      ],
                    ),
                  ),
                  coordinateUnit: CoordinateUnit.point,
                  region: AnnotationRegion.chart,
                  x: best + 0,
                  y: bestY + 2)
              : dummyAnnotation,
        ],
      );
    }

    Widget leaderBoardItem(LeaderboardItem item, int index) {
      bool isMe = item.uid == userData.uid;
      Color color = index == 0
          ? Color(0xffFFD700)
          : index == 1
              ? Color(0xffC0C0C0)
              : index == 2
                  ? Color(0xffCD7F32)
                  : isMe
                      ? primaryColor
                      : Colors.white;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: AutoSizeText(
              "${index + 1}",
              style: TextStyle(
                fontFamily: "Arcade",
                color: color,
              ),
              maxLines: 1,
              minFontSize: 8,
            ),
          ),
          Expanded(
            flex: 8,
            child: AutoSizeText(
              "   ${item.username}" + (isMe ? " (You)" : ""),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
              maxLines: 1,
              minFontSize: 8,
            ),
          ),
          // Spacer(),
          Expanded(
            flex: 2,
            child: AutoSizeText(
              "${Service().intToTimeLeft(item.time)} (${item.move})",
              style: TextStyle(color: color),
              textAlign: TextAlign.right,
              maxLines: 1,
              minFontSize: 8,
            ),
          )
        ],
      );
    }

    Widget board(List<ChartData> chartData) {
      int? current = gridSize == widget.gridSize
          ? widget.currentTime
          : userData.times[grid]!;
      int best = userData.times[grid]!;
      rank = (Service()
              .calculatePercentile(chartData, current ?? (best), getRank: true))
          .toInt();
      return StreamBuilder<List<LeaderboardItem>>(
          stream: DatabaseService.instance.fetchLeaderBoards(grid),
          builder: (context, snapshot) {
            bool isDone = !snapshot.hasError &&
                snapshot.hasData &&
                snapshot.data != null &&
                snapshot.connectionState != ConnectionState.waiting;
            if (!isDone) {
              return Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.zero),
                  border: Border.all(
                    color: Colors.white,
                  ),
                ),
                child: const Center(
                    child: Spinner(
                  text: "Fetching...",
                )),
              );
            }
            List<LeaderboardItem> data = snapshot.data!;
            data.sort((a, b) {
              int cmp = a.time.compareTo(b.time);
              if (cmp != 0) return cmp;
              return a.move.compareTo(b.move);
            });
            int myPosition = data.indexWhere((e) => e.uid == userData.uid);
            if (animateToMe && itemScrollController.isAttached) {
              if (myPosition > 10) {
                _scrollToMe(myPosition);
              } else if (myPosition.isNegative && rank != 1) {
                _scrollToMe(data.length);
              }
            }
            return Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.zero),
                  border: Border.all(
                    color: Colors.white,
                  )),
              child: ScrollConfiguration(
                behavior: MyCustomScrollBehavior(),
                child: ScrollablePositionedList.separated(
                  separatorBuilder: (context, index) => Divider(
                    indent: 24,
                    endIndent: 24,
                  ),
                  itemCount: data.length + (!myPosition.isNegative ? 0 : 1),
                  // physics: const BouncingScrollPhysics(),
                  itemScrollController: itemScrollController,
                  itemBuilder: ((context, index) {
                    if (index == data.length) {
                      LeaderboardItem item = LeaderboardItem(
                          uid: userData.uid,
                          username: userData.username,
                          move: widget.currentMove ?? userData.moves[grid]!,
                          time: widget.currentTime ?? userData.times[grid]!);
                      return rank == 1
                          ? Container()
                          : leaderBoardItem(item, rank - 1);
                    }
                    LeaderboardItem item = data[index];

                    return leaderBoardItem(item, index);
                  }),
                ),
              ),
            );
          });
    }

    return DefaultTextStyle(
      style: Theme.of(context)
          .textTheme
          .headline5!
          .copyWith(fontFamily: "Glacial", fontSize: 18),
      child: FutureBuilder(
          future: future,
          builder: (context, AsyncSnapshot<CommunityScores> snapshot) {
            bool isDone = snapshot.connectionState == ConnectionState.done;
            List<ChartData> timeChartData =
                isDone ? snapshot.data!.times[grid]! : [];
            List<ChartData> moveChartData =
                isDone ? snapshot.data!.moves[grid]! : [];
            return Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Row(
                      //   children: [
                      //     DefaultTextStyle(
                      //       style: TextStyle(fontFamily: "Arcade"),
                      //       child: MyButton(
                      //         label: "${gridSize}x$gridSize",
                      //         onPressed: () {
                      //           setState(() {
                      //             gridSize = gridSize == 3 ? 4 : 3;
                      //           });
                      //         },
                      //         expanded: false,
                      //       ),
                      //     ),
                      //     IconButton(
                      //       icon: Icon(Icons.close),
                      //       onPressed: () {
                      //         Navigator.of(context).pop();
                      //         AudioService.instance.vibrate();
                      //       },
                      //     ),
                      //   ],
                      // ),
                      SizedBox(
                        height: 50,
                      ),
                      AutoSizeText(
                        widget.checking ? "LEADERBOARDS" : "BRAVO!",
                        style: TextStyle(fontFamily: "Arcade"),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        minFontSize: 8,
                      ),
                      SizedBox(
                        height: maxHeight * 0.05,
                      ),
                      Expanded(
                        child: board(timeChartData),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      // Spacer(),
                      // Container(
                      //   height: maxHeight * 0.3,
                      //   child: isDone
                      //       ? chart(
                      //           isDone,
                      //           timeChartData,
                      //           isTime: true,
                      //           current: widget.currentTime,
                      //           best: widget.userData.moves[grid]!,
                      //         )
                      //       : const Center(child: Spinner()),
                      // ),
                      // Container(
                      //   height: maxHeight * 0.3,
                      //   child: isDone
                      //       ? chart(
                      //           isDone,
                      //           moveChartData,
                      //           isTime: false,
                      //           current: widget.currentMove,
                      //           best: widget.userData.moves[grid]!,
                      //         )
                      //       : Container(),
                      // ),
                    ],
                  ),
                ),
                widget.userData.moves[grid]! != 0 &&
                        widget.userData.times[grid]! != 0
                    ? Positioned(
                        bottom: 0,
                        right: 0,
                        child: MyButton(
                          label: "Share",
                          tooltip: "Share to your Twitter",
                          expanded: false,
                          shouldAnimateEntry: false,
                          onPressed: () {
                            Service().shareToTwitter(
                                gridSize,
                                widget.userData.moves[grid]!,
                                Service().intToTimeLeft(
                                    widget.userData.times[grid]!),
                                movesPercentile,
                                timesPercentile,
                                rank);
                          },
                        ),
                      )
                    : Container(),
                Positioned(
                  top: 0,
                  left: 0,
                  child: DefaultTextStyle(
                    style: TextStyle(fontFamily: "Arcade"),
                    child: MyButton(
                      label: "${gridSize}x$gridSize",
                      tooltip: "Switch leaderboards for the grid size",
                      onPressed: () {
                        setState(() {
                          gridSize = gridSize == 3 ? 4 : 3;
                        });
                      },
                      expanded: false,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    tooltip: "Close",
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                      AudioService.instance.vibrate();
                    },
                  ),
                )
              ],
            );
          }),
    );
  }
}
