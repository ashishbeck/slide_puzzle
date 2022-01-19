import 'dart:math';

import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/code/providers.dart';

class Service {
  changePosition(
      List<TilesModel> tileList, TilesModel thisTile, TilesModel whiteTile,
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
      replaceableTile.currentIndex = whiteTile.currentIndex;
      whiteTile.currentIndex = temp;
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
}
