import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:slide_puzzle/code/audio.dart';
import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/code/store.dart';
import 'package:slide_puzzle/screen/app.dart';
import 'package:slide_puzzle/screen/puzzle.dart';
import 'package:slide_puzzle/ui/dialog.dart';

class VisibleLeaderboardTool extends StatelessWidget {
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
  Widget build(BuildContext context) {
    UserData? userData = context.read<UserData?>();
    List<Widget> children = [
      Expanded(
        child: IconButton(
          tooltip: "Toggle visibility of numbers (practice mode)",
          onPressed: () {
            if (configProvider.showNumbers &&
                (configProvider.gamestate == GameState.started ||
                    configProvider.gamestate == GameState.finished)) {
              int gridSize = tileProvider.gridSize;
              homeKey.currentState!
                  .createTiles(gridSize: gridSize, shuffle: false);
            }
            configProvider.toggleNumbersVisibility();

            if (Storage.instance.showPracticeMode &&
                configProvider.showNumbers) {
              Storage.instance.seenPracticeMode();
              showDialog(
                  context: context,
                  barrierColor: Colors.black.withOpacity(0.95),
                  builder: (context) {
                    return const Center(
                      child: Text(
                        "This is the practice mode where you can see"
                        " numbers on top of individual tiles.\nYour score will NOT"
                        " be counted towards the Leaderboards!",
                        style: TextStyle(fontFamily: "Glacial", fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    );
                  });
            }
            AudioService.instance.vibrate();
          },
          icon: Icon(
              configProvider.showNumbers ? Icons.pin : Icons.visibility_off),
        ),
      ),
      // isTall ? Divider() : VerticalDivider(),
      Expanded(
        child: IconButton(
          tooltip: "Show Leaderboards",
          onPressed: () {
            puzzleKey.currentState!.launchScoreBoard(
                scoreProvider, userData, configProvider,
                checking: true);
            AudioService.instance.vibrate();
          },
          icon: Icon(Icons.leaderboard),
        ),
      ),
    ];

    return Container(
      child: IntrinsicHeight(
        child: IntrinsicWidth(
          child: isTall
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
