import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slide_puzzle/code/audio.dart';

import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/screen/puzzle.dart';

class VisibleLeaderboardTool extends StatelessWidget {
  final bool isTall;
  final ConfigProvider configProvider;
  final ScoreProvider scoreProvider;
  const VisibleLeaderboardTool({
    Key? key,
    required this.isTall,
    required this.configProvider,
    required this.scoreProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserData? userData = context.read<UserData?>();
    List<Widget> children = [
      Expanded(
        child: IconButton(
          onPressed: () {
            configProvider.toggleNumbersVisibility();
            AudioService.instance.vibrate();
          },
          icon: Icon(
              configProvider.showNumbers ? Icons.pin : Icons.visibility_off),
        ),
      ),
      // isTall ? Divider() : VerticalDivider(),
      Expanded(
        child: IconButton(
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
