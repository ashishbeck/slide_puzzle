import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/code/service.dart';

class Scores extends StatefulWidget {
  const Scores({Key? key}) : super(key: key);

  @override
  _ScoresState createState() => _ScoresState();
}

class _ScoresState extends State<Scores> {
  @override
  Widget build(BuildContext context) {
    ScoreProvider scoreProvider = context.watch<ScoreProvider>();
    return Container(
      child: Row(children: [
        Text(scoreProvider.moves.toString()),
        const SizedBox(
          width: 8,
        ),
        Text(Service().intToTimeLeft(scoreProvider.seconds)),
      ]),
    );
  }
}
