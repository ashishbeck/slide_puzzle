import 'package:flutter/cupertino.dart';
import 'package:slide_puzzle/code/models.dart';

class TileProvider extends ChangeNotifier {
  List<TilesModel> _tileList = [];
  List<TilesModel> get getTileList => _tileList;

  void createTiles(List<TilesModel> newTiles) {
    _tileList.clear();
    _tileList.addAll(newTiles);
    notifyListeners();
  }

  // void swapTiles(int currentIndex, int newIndex) {
  //   int temp = currentIndex;
  //   _tileList[currentIndex].currentIndex = _tileList[newIndex].currentIndex;
  //   _tileList[newIndex].currentIndex = temp;
  //   notifyListeners();
  // }

  void updateNotifiers() => notifyListeners();
}

class TweenProvider extends ChangeNotifier {
  double? _tweenTopOffset;
  double? get tweenTopOffset => _tweenTopOffset;
  double? _tweenLeftOffset;
  double? get tweenLeftOffset => _tweenLeftOffset;
  int? _userRow;
  int? get userRow => _userRow;
  int? _userColumn;
  int? get userColumn => _userColumn;

  void setData({
    double? tweenTopOffset,
    double? tweenLeftOffset,
    int? userRow,
    int? userColumn,
  }) {
    _tweenTopOffset = tweenTopOffset;
    _tweenLeftOffset = tweenLeftOffset;
    _userRow = userRow;
    _userColumn = userColumn;
    notifyListeners();
  }
}

int defaultTime = 200;

class ConfigProvider extends ChangeNotifier {
  Duration _duration = Duration(milliseconds: defaultTime);
  Duration get duration => _duration;

  void setDuration(Duration duration) {
    _duration = duration;
    notifyListeners();
  }

  void resetDuration() {
    _duration = Duration(milliseconds: defaultTime);
  }
}
