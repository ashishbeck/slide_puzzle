import 'package:flutter/cupertino.dart';
import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/screen/app.dart';

class TileProvider extends ChangeNotifier {
  int _gridSize = 4;
  int get gridSize => _gridSize;
  List<TilesModel> _tileList = [];
  List<TilesModel> get getTileList => _tileList;
  List<int> _images = List.generate(6, (index) => index + 1);
  List<int> get images => _images;
  int _currentImage = 1;
  int get currentImage => _currentImage;

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

  void changeImage(int index) {
    _currentImage = index;
    notifyListeners();
  }

  void changeGridSize(int index) {
    _gridSize = index;
    homeKey.currentState!.createTiles(gridSize: index, isChangingGrid: true);
    notifyListeners();
  }
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

class ConfigProvider extends ChangeNotifier {
  Duration _duration = Duration(milliseconds: defaultTime);
  Duration get duration => _duration;
  Curve _curve = defaultCurve;
  Curve get curve => _curve;
  bool _previewedButtons = false;
  bool get previewedButtons => _previewedButtons;
  bool _showNumbers = false;
  bool get showNumbers => _showNumbers;

  void setDuration(Duration duration, {Curve? curve}) {
    _duration = duration;
    _curve = curve ?? defaultCurve;
    // notifyListeners();
  }

  void resetDuration() {
    _duration = Duration(milliseconds: defaultTime);
    _curve = defaultCurve;
  }

  void seenButton() => _previewedButtons = true;

  void toggleNumbersVisibility() {
    _showNumbers = !_showNumbers;
    notifyListeners();
  }
}
