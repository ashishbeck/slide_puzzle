import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

import 'package:slide_puzzle/code/audio.dart';
import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/code/store.dart';
import 'package:slide_puzzle/screen/app.dart';
import 'package:slide_puzzle/screen/puzzle.dart';
import 'package:slide_puzzle/ui/dialog.dart';
import 'package:slide_puzzle/ui/rive_icons.dart';

class VisibleLeaderboardTool extends StatefulWidget {
  final bool isTall;
  final ConfigProvider configProvider;
  final ScoreProvider scoreProvider;
  final TileProvider tileProvider;
  const VisibleLeaderboardTool({
    Key? key,
    required this.isTall,
    required this.configProvider,
    required this.scoreProvider,
    required this.tileProvider,
  }) : super(key: key);

  @override
  State<VisibleLeaderboardTool> createState() => _VisibleLeaderboardToolState();
}

class _VisibleLeaderboardToolState extends State<VisibleLeaderboardTool> {
  final riveInstance = RiveIcons.instance;
  // Artboard? _numbersArtboard;
  // SMIInput<bool>? _isNumbersVisible;
  // Artboard? _leaderboardArtboard;
  // RiveAnimationController? _leaderboardController;

  // @override
  // void initState() {
  //   super.initState();

  //   rootBundle.load('assets/rive/toolbar.riv').then(
  //     (data) async {
  //       final file = RiveFile.import(data);

  //       final numbersArtboard = file.artboardByName("visible");
  //       final leaderboardArtboard = file.artboardByName("leaderboard");
  //       var numbersController =
  //           StateMachineController.fromArtboard(numbersArtboard!, 'toggle');
  //       var leaderboardController =
  //           OneShotAnimation("trigger", autoplay: false);
  //       if (numbersController != null) {
  //         numbersArtboard.addController(numbersController);
  //         _isNumbersVisible = numbersController.findInput('isVisible');
  //       }
  //       leaderboardArtboard!.addController(leaderboardController);
  //       setState(() {
  //         _numbersArtboard = numbersArtboard;
  //         _leaderboardArtboard = leaderboardArtboard;
  //         _leaderboardController = leaderboardController;
  //       });
  //     },
  //   );
  // }

  _animate(ConfigProvider configProvider) {
    if (riveInstance.isNumbersVisible != null) {
      if (!configProvider.showNumbers) {
        riveInstance.isNumbersVisible!.value = false;
      } else {
        riveInstance.isNumbersVisible!.value = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    UserData? userData = context.read<UserData?>();
    ConfigProvider configProvider = context.watch<ConfigProvider>();
    _animate(configProvider);
    List<Widget> children = [
      Expanded(
        child: IconButton(
          tooltip: "Toggle visibility of numbers (practice mode)",
          onPressed: () {
            if (widget.configProvider.showNumbers &&
                (widget.configProvider.gamestate == GameState.started ||
                    widget.configProvider.gamestate == GameState.finished)) {
              int gridSize = widget.tileProvider.gridSize;
              homeKey.currentState!
                  .createTiles(gridSize: gridSize, shuffle: false);
            }
            widget.configProvider.toggleNumbersVisibility();

            if (Storage.instance.showPracticeMode &&
                widget.configProvider.showNumbers) {
              Storage.instance.seenPracticeMode();
              showDialog(
                  context: context,
                  barrierColor: Colors.black.withOpacity(0.95),
                  builder: (context) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "This is the practice mode where you can see"
                          " numbers on top of individual tiles.\nYour score will NOT"
                          " be counted towards the Leaderboards!",
                          style: TextStyle(fontFamily: "Glacial", fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  });
            } else if (widget.configProvider.showNumbers) {
              Widget text = const Text(
                "Practice Mode Activated",
                style: TextStyle(
                    fontSize: 24, color: Colors.white, fontFamily: "Arcade"),
                textAlign: TextAlign.center,
              );
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(MySnackbar("Practice Mode Activated", context));
            }
            AudioService.instance.button();
            AudioService.instance.vibrate();
          },
          icon: riveInstance.numbersArtboard == null
              ? Rive(artboard: RuntimeArtboard())
              : Rive(artboard: riveInstance.numbersArtboard!),
        ),
      ),
      // isTall ? Divider() : VerticalDivider(),
      Expanded(
        child: IconButton(
          tooltip: "Show Leaderboards",
          onPressed: () {
            puzzleKey.currentState!.launchScoreBoard(
                widget.scoreProvider, userData, widget.configProvider,
                checking: true);
            AudioService.instance.button();
            AudioService.instance.vibrate();
            if (riveInstance.leaderboardController != null) {
              riveInstance.leaderboardController!.isActive = true;
            }
          },
          icon: riveInstance.leaderboardArtboard == null
              ? Rive(artboard: RuntimeArtboard())
              : Rive(artboard: riveInstance.leaderboardArtboard!),
        ),
      ),
    ];

    return Container(
      child: IntrinsicHeight(
        child: IntrinsicWidth(
          child: widget.isTall
              ? Column(
                  children: children,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                ),
        ),
      ),
    );
  }
}
