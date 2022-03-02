import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/code/service.dart';

class Scores extends StatefulWidget {
  final bool isTall;
  const Scores({
    Key? key,
    required this.isTall,
  }) : super(key: key);

  @override
  _ScoresState createState() => _ScoresState();
}

class _ScoresState extends State<Scores> {
  @override
  Widget build(BuildContext context) {
    ScoreProvider scoreProvider = context.watch<ScoreProvider>();
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Tooltip(
            message: "Number of moves since last shuffled",
            child: AutoSizeText(
              "${scoreProvider.moves} moves",
              maxLines: 1,
              minFontSize: 8,
              textAlign: TextAlign.center,
            ),
          ),
          Tooltip(
            message: "Time elapsed since last shuffled",
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                widget.isTall
                    ? AutoSizeText(
                        Service().intToTimeLeft(scoreProvider.seconds),
                        maxLines: 1,
                        minFontSize: 8,
                      )
                    : Expanded(
                        child: AutoSizeText(
                          Service().intToTimeLeft(scoreProvider.seconds),
                          maxLines: 1,
                          minFontSize: 8,
                        ),
                      ),
                Icon(Icons.timer),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
