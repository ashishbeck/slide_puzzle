import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slide_puzzle/code/audio.dart';
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
  late Future<CommunityScores> future;
  int gridSize = 0;
  Map<String, int> addExtraData = {"three": 0, "four": 0};

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
      double timesPercentileData =
          (Service().calculatePercentile(chartData, current ?? (best)));
      double movesPercentileData =
          Service().calculatePercentile(chartData, current ?? (best));

      timesPercentile = timesPercentileData.toInt() == timesPercentileData
          ? timesPercentileData.toInt().toString()
          : timesPercentileData.toStringAsFixed(2);
      movesPercentile = movesPercentileData.toInt() == movesPercentileData
          ? movesPercentileData.toInt().toString()
          : movesPercentileData.toStringAsFixed(2);

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
        print(total);
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

    return DefaultTextStyle(
      style: Theme.of(context)
          .textTheme
          .headline5!
          .copyWith(fontFamily: "Glacial"),
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
                      AutoSizeText(
                        widget.checking ? "STATS" : "BRAVO!",
                        style: TextStyle(fontFamily: "Arcade"),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        minFontSize: 8,
                      ),
                      // SizedBox(
                      //   height: maxHeight * 0.05,
                      // ),
                      // Spacer(),
                      Container(
                        height: maxHeight * 0.3,
                        child: isDone
                            ? chart(
                                isDone,
                                timeChartData,
                                isTime: true,
                                current: widget.currentTime,
                                best: widget.userData.moves[grid]!,
                              )
                            : Center(child: CircularProgressIndicator()),
                      ),
                      Container(
                        height: maxHeight * 0.3,
                        child: isDone
                            ? chart(
                                isDone,
                                moveChartData,
                                isTime: false,
                                current: widget.currentMove,
                                best: widget.userData.moves[grid]!,
                              )
                            : Center(child: CircularProgressIndicator()),
                      ),
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
                          expanded: false,
                          shouldAnimateEntry: false,
                          onPressed: () {
                            Service().shareToTwitter(
                              gridSize,
                              widget.userData.moves[grid]!,
                              Service()
                                  .intToTimeLeft(widget.userData.times[grid]!),
                              movesPercentile,
                              timesPercentile,
                            );
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
