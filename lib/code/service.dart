import 'dart:io';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:slide_puzzle/code/audio.dart';
import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/code/providers.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:vibration/vibration.dart';

class Service {
  bool shouldVibrate = true;

  List<TilesModel> changePosition(
      List<TilesModel> tileList,
      TilesModel thisTile,
      TilesModel whiteTile,
      ScoreProvider scoreProvider,
      ConfigProvider configProvider,
      {int gridSize = 1}) {
    int distance =
        ((thisTile.currentIndex - whiteTile.currentIndex) ~/ gridSize);
    int whiteIndex = whiteTile.currentIndex;
    for (var i = 1; i <= distance.abs(); i++) {
      TilesModel replaceableTile = tileList.firstWhere((element) =>
          element.currentIndex ==
          (distance < 0
              ? whiteIndex - gridSize * i
              : whiteIndex + gridSize * i));
      // if (tileProvider != null) {
      // tileProvider.swapTiles(
      //     replaceableTile.currentIndex, whiteTile.currentIndex);
      // }
      int temp = replaceableTile.currentIndex;
      var tempCoords = replaceableTile.coordinates;
      replaceableTile.currentIndex = whiteTile.currentIndex;
      replaceableTile.coordinates = whiteTile.coordinates;
      whiteTile.currentIndex = temp;
      whiteTile.coordinates = tempCoords;
    }
    AudioService.instance.slide(Duration(milliseconds: defaultTime * 1));
    AudioService.instance.vibrate();
    if (configProvider.gamestate == GameState.waiting) {
      // if (!scoreProvider.isRunning && scoreProvider.beginState) {
      scoreProvider.beginTimer();
      // }
    }
    if (configProvider.gamestate == GameState.started) {
      scoreProvider.incrementMoves();
    }
    return tileList;
  }

  List<TilesModel>? moveWhite(List<TilesModel> tileList, Direction direction,
      ScoreProvider scoreProvider, ConfigProvider configProvider) {
    int gridSize = sqrt(tileList.length).toInt();
    TilesModel whiteTile = tileList.singleWhere((element) => element.isWhite);
    int row = whiteTile.coordinates.row;
    int column = whiteTile.coordinates.column;
    bool left = column == 0;
    bool right = column == gridSize - 1;
    bool top = row == 0;
    bool bottom = row == gridSize - 1;
    switch (direction) {
      case Direction.left:
        if (right) break;
        var replaceableTile = tileList.singleWhere((element) =>
            element.coordinates.row == row &&
            element.coordinates.column == column + 1);
        return changePosition(
          tileList,
          replaceableTile,
          whiteTile,
          scoreProvider,
          configProvider,
        );
      case Direction.down:
        if (top) break;
        var replaceableTile = tileList.singleWhere((element) =>
            element.coordinates.row == row - 1 &&
            element.coordinates.column == column);
        return changePosition(
          tileList,
          replaceableTile,
          whiteTile,
          scoreProvider,
          configProvider,
          gridSize: gridSize,
        );
      case Direction.right:
        if (left) break;
        var replaceableTile = tileList.singleWhere((element) =>
            element.coordinates.row == row &&
            element.coordinates.column == column - 1);
        return changePosition(
          tileList,
          replaceableTile,
          whiteTile,
          scoreProvider,
          configProvider,
        );
      case Direction.up:
        if (bottom) break;
        var replaceableTile = tileList.singleWhere((element) =>
            element.coordinates.row == row + 1 &&
            element.coordinates.column == column);
        return changePosition(
            tileList, replaceableTile, whiteTile, scoreProvider, configProvider,
            gridSize: gridSize);
    }
  }

  bool isSolvable(List<TilesModel> list) {
    int len = list.length;
    int gridSize = sqrt(len).toInt();
    int inversions = 0;
    for (var i = 0; i < len; i++) {
      if (!list[i].isWhite) {
        for (var j = i + 1; j < len; j++) {
          if (list[i].currentIndex > list[j].currentIndex && !list[j].isWhite) {
            inversions++;
          }
        }
      }
    }
    if (gridSize.isOdd) {
      return inversions.isEven;
    }
    TilesModel whiteTile = list.firstWhere((element) => element.isWhite);
    int row = (whiteTile.currentIndex / gridSize).floor();
    if ((gridSize - row).isOdd) {
      return inversions.isEven;
    } else {
      return inversions.isOdd;
    }
  }

  bool isSolved(List<TilesModel> list) {
    return list
        .every((element) => element.currentIndex == element.defaultIndex);
  }

  Future<List<String>> getSolution(List<TilesModel> tileList) async {
    List<TilesModel> list = List.from(tileList)
      ..sort((a, b) => a.currentIndex.compareTo(b.currentIndex));
    String tiles = "";
    for (var e in list) {
      tiles = tiles + (e.defaultIndex + 1).toString() + " ";
    }
    // why the code below does not work I have no idea
    // list.map((e) => tiles = tiles + (e.defaultIndex + 1).toString());
    // print(tiles);
    String val = tiles
        .substring(0, tiles.length - 1)
        .replaceAll(",", "")
        .replaceAll(tileList.length.toString(), "0");
    // .replaceAll(" ", "%20");
    // print(val);
    var url =
        Uri.parse("https://npuzzlesolver-ajp37iulda-ez.a.run.app/?tiles=$val");
    try {
      var response = await http.get(url);
      var body = (response.body);
      // print(body);
      return body.split(", ");
    } catch (e) {
      print(e);
    }
    return [];
  }

  bool checkIfParent(Direction thisMove, Direction? previousMove) {
    bool allowed = true;
    if (previousMove == null) {
      return false;
    }
    switch (thisMove) {
      case Direction.left:
        if (previousMove == Direction.right) allowed = false;
        break;
      case Direction.right:
        if (previousMove == Direction.left) allowed = false;
        break;
      case Direction.up:
        if (previousMove == Direction.down) allowed = false;
        break;
      case Direction.down:
        if (previousMove == Direction.up) allowed = false;
        break;
    }
    return !allowed;
  }

  String intToTimeLeft(int value) {
    int h, m, s;
    h = value ~/ 3600;
    m = ((value - h * 3600)) ~/ 60;
    s = value - (h * 3600) - (m * 60);
    String hourLeft =
        h.toString().length < 2 ? "0" + h.toString() : h.toString();
    String minuteLeft =
        m.toString().length < 2 ? "0" + m.toString() : m.toString();
    String secondsLeft =
        s.toString().length < 2 ? "0" + s.toString() : s.toString();
    String result = "${h == 0 ? "" : hourLeft + ":"}$minuteLeft:$secondsLeft";
    return result;
  }

  double calculatePercentile(List<ChartData> chartData, int best,
      {bool getRank = false}) {
    // It is not really percentile but a comparison so had to tweak the
    // formula a bit
    int totalPlayers = 0;
    int totalAboveMe = 0;
    int totalBelowMe = 0;
    int sameRank = 0;
    for (var item in chartData) {
      totalPlayers += item.y;
      if (item.x > best) {
        totalAboveMe += item.y;
      } else if (item.x == best && item.y == 1) {
        // If the best, this 1 value belongs to you so you're better than
        // everyone else and it's a 100% (not percentile) better performance.
        // If it's an arbitrary number in between the data set, it doesn't
        // matter if the final percentage is slightly off
        // totalAboveMe += 1;
        sameRank = 1;
      } else if (item.x < best) {
        totalBelowMe += item.y;
      }
    }
    if (getRank) {
      return (totalBelowMe + 1).toDouble();
    }
    return (totalAboveMe / totalPlayers) * 100;
  }

  void shareToTwitter(int gridSize, int moves, String time, String mPerc,
      String tPerc, int rank) {
    String grid = "${gridSize}x$gridSize";
    String text = "I just solved the $grid Retro Puzzle in $moves moves under "
        "$time 😎 I am rank $rank in the leaderboards 💪\n\nThink you can "
        "beat me? 😉 Try it out-\n"
        "&url=https://n-puzzle-solver-1.web.app/";
    Uri uri = Uri.parse("https://twitter.com/intent/tweet?text=" + text);
    launch(uri.toString());
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}
