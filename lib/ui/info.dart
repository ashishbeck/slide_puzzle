import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:slide_puzzle/code/audio.dart';
import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/ui/button.dart';

class InfoDialog extends StatefulWidget {
  const InfoDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<InfoDialog> createState() => _InfoDialogState();
}

class _InfoDialogState extends State<InfoDialog> {
  bool isHovering = false;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isTall = height > width * 0.85;
    final dialog = Padding(
      padding: EdgeInsets.symmetric(
          vertical: 16.0, horizontal: isTall ? 16 : width * 0.25),
      child: DefaultTextStyle(
        style:
            TextStyle(fontFamily: "Glacial", color: Colors.white, fontSize: 18),
        // textAlign: TextAlign.start,
        child: Center(
          child: ListView(
            shrinkWrap: true,
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "How to play",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                  "\nThe objective of the game is to arrange all the tiles in the correct "
                  "order to recreate the chosen image\n"),
              Text(
                "This game can be played with:\n - Keyboard arrow keys (on devices with a keyboard) to move the tiles near the empty space\n"
                " - Screen taps or mouse clicks to move the corresponding tile\n"
                " - Drag n drop neighbouring tiles\n"
                " - Flick or swipe the neighbouring tiles\n"
                "\n Tip: You can move multiple tiles at once when there is space\n",
              ),
              Text(
                  "Try to get your name on the leaderboard if you can\nGood Luck!"),
              Center(
                child: MyButton(
                  label: "Got it",
                  onPressed: () => Navigator.of(context).pop(),
                  expanded: false,
                  shouldAnimateEntry: false,
                  tooltip: "Close this",
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return MouseRegion(
        onEnter: (_) => setState(() => isHovering = true),
        onExit: (_) => setState(() => isHovering = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
            onTap: () {
              AudioService.instance.vibrate();
              AudioService.instance.button();
              showDialog(
                  context: context,
                  barrierColor: Colors.black.withOpacity(0.98),
                  builder: (context) {
                    return dialog;
                  });
            },
            child: Text(
              "Info",
              style: TextStyle(color: isHovering ? primaryColor : Colors.white),
            )));
  }
}
