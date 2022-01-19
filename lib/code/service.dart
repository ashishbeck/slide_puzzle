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
}
