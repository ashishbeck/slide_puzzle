import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class RiveIcons {
  static final RiveIcons instance = RiveIcons._init();
  RiveIcons._init();

  Artboard? _audioArtboard;
  Artboard? get audioArtboard => _audioArtboard;
  SMIInput<bool>? _isAudioVisible;
  SMIInput<bool>? get isAudioVisible => _isAudioVisible;
  Artboard? _vibrationArtboard;
  Artboard? get vibrationArtboard => _vibrationArtboard;
  SMIInput<bool>? _isVibrationVisible;
  SMIInput<bool>? get isVibrationVisible => _isVibrationVisible;
  Artboard? _numbersArtboard;
  Artboard? get numbersArtboard => _numbersArtboard;
  SMIInput<bool>? _isNumbersVisible;
  SMIInput<bool>? get isNumbersVisible => _isNumbersVisible;
  Artboard? _leaderboardArtboard;
  Artboard? get leaderboardArtboard => _leaderboardArtboard;
  RiveAnimationController? _leaderboardController;
  RiveAnimationController? get leaderboardController => _leaderboardController;
  Artboard? _timerArtboard;
  Artboard? get timerArtboard => _timerArtboard;
  SMIInput<bool>? _isTimerRunning;
  SMIInput<bool>? get isTimerRunning => _isTimerRunning;

  init() async {
    final data = await rootBundle.load('assets/rive/toolbar.riv');
    final file = RiveFile.import(data);
    final audioArtboard = file.artboardByName("audio");
    final vibrationArtboard = file.artboardByName("vibration");
    final numbersArtboard = file.artboardByName("visible");
    final leaderboardArtboard = file.artboardByName("leaderboard");
    final timerArtboard = file.artboardByName("timer");
    var audioController =
        StateMachineController.fromArtboard(audioArtboard!, 'toggle');
    var vibrationController =
        StateMachineController.fromArtboard(vibrationArtboard!, 'toggle');
    var numbersController =
        StateMachineController.fromArtboard(numbersArtboard!, 'toggle');
    var leaderboardController = OneShotAnimation("trigger", autoplay: false);
    var timerController =
        StateMachineController.fromArtboard(timerArtboard!, 'toggle');
    if (audioController != null) {
      audioArtboard.addController(audioController);
      _isAudioVisible = audioController.findInput('isVisible');
    }
    if (vibrationController != null) {
      vibrationArtboard.addController(vibrationController);
      _isVibrationVisible = vibrationController.findInput('isVisible');
    }
    if (numbersController != null) {
      numbersArtboard.addController(numbersController);
      _isNumbersVisible = numbersController.findInput('isVisible');
    }
    if (timerController != null) {
      timerArtboard.addController(timerController);
      _isTimerRunning = timerController.findInput('isRunning');
    }
    leaderboardArtboard!.addController(leaderboardController);
    _audioArtboard = audioArtboard;
    _vibrationArtboard = vibrationArtboard;
    _numbersArtboard = numbersArtboard;
    _leaderboardArtboard = leaderboardArtboard;
    _leaderboardController = leaderboardController;
    _timerArtboard = timerArtboard;
  }
}
