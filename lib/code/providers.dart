import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:slide_puzzle/code/audio.dart';
import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/code/service.dart';
import 'package:slide_puzzle/code/store.dart';
import 'package:slide_puzzle/screen/app.dart';

class TileProvider extends ChangeNotifier {
  int _gridSize = 4;
  int get gridSize => _gridSize;
  List<TilesModel> _tileList = [];
  List<TilesModel> get getTileList => _tileList;
  List<String> _images = []; //List.generate(6, (index) => index + 1);
  List<String> get images => _images;
  int _currentImage = 0;
  int get currentImage => _currentImage;

  void createTiles(List<TilesModel> newTiles) {
    _tileList.clear();
    _tileList.addAll(newTiles);
    notifyListeners();
  }

  void updateImages(BuildContext context) async {
    final manifestJson =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final list = json
        .decode(manifestJson)
        .keys
        .where((String key) => key.startsWith('assets/images'))
        .toList();
    _images = list;
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
    homeKey.currentState!
        .createTiles(gridSize: index, isChangingGrid: true, shuffle: false);
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
  Map<String, bool> _previewedButtons = {};
  Map<String, bool> get previewedButtons => _previewedButtons;
  Map<String, bool> _entryAnimationDone = {};
  Map<String, bool> get entryAnimationDone => _entryAnimationDone;
  bool _showNumbers = false;
  bool get showNumbers => _showNumbers;
  bool _hasStarted = false;
  bool get hasStarted => _hasStarted;
  GameState _gameState = GameState.waiting;
  GameState get gamestate => _gameState;
  bool _muted = !Storage.instance.sounds;
  bool get muted => _muted;
  bool _vibrationsOff = !Storage.instance.vibrations;
  bool get vibrationsOff => _vibrationsOff;
  bool _solvedByAI = false;
  bool get solvedByAI => _solvedByAI;

  void setDuration(Duration duration, {Curve? curve}) {
    _duration = duration;
    _curve = curve ?? defaultCurve;
    // notifyListeners();
  }

  void resetDuration() {
    _duration = Duration(milliseconds: defaultTime);
    _curve = defaultCurve;
  }

  void seenButton(String name) => _previewedButtons[name] = true;

  void seenEntryAnimation(String name) => _entryAnimationDone[name] = true;

  void toggleNumbersVisibility() {
    _showNumbers = !_showNumbers;
    notifyListeners();
  }

  void start() {
    _gameState = GameState.started;
    _solvedByAI = false;
    notifyListeners();
  }

  void finish({bool solvedByAI = false}) {
    _gameState = GameState.finished;
    _solvedByAI = solvedByAI;
    // notifyListeners();
  }

  void wait() {
    _gameState = GameState.waiting;
    _solvedByAI = false;
    notifyListeners();
  }

  void aiSolving() {
    _gameState = GameState.aiSolving;
    notifyListeners();
  }

  void toggleSound() {
    _muted = !_muted;
    AudioService.instance.isMuted = _muted;
    Storage.instance.toggleSounds();
    notifyListeners();
  }

  void toggleVibration() {
    _vibrationsOff = !_vibrationsOff;
    AudioService.instance.shouldVibrate = !_vibrationsOff;
    Storage.instance.toggleVibrations();
    notifyListeners();
  }
}

class ScoreProvider extends ChangeNotifier {
  int _moves = 0;
  int get moves => _moves;
  int _seconds = 0;
  int get seconds => _seconds;
  bool _isRunning = false;
  bool get isRunning => _isRunning;
  bool _beginState = true;
  bool get beginState => _beginState;
  Timer? thisTimer;

  void beginTimer() {
    _isRunning = true;
    _beginState = false;
    resetScores();
    thisTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) {
        timer.cancel();
      } else {
        incrementSeconds();
      }
    });
  }

  void restart() {
    _beginState = true;
    stopTimer();
    resetScores();
    notifyListeners();
  }

  void stopTimer() {
    _isRunning = false;
    if (thisTimer != null) thisTimer!.cancel();
  }

  void incrementMoves() {
    _moves += 1;
    notifyListeners();
  }

  void incrementSeconds() {
    _seconds += 1;
    notifyListeners();
  }

  void resetScores() {
    _moves = 0;
    _seconds = 0;
    notifyListeners();
  }
}

enum GameState { waiting, started, finished, aiSolving }
