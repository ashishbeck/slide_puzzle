import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slide_puzzle/code/constants.dart';

import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/ui/bordered_container.dart';
import 'package:slide_puzzle/ui/button.dart';
import 'package:slide_puzzle/ui/scores.dart';
import 'package:slide_puzzle/ui/sound_vibration.dart';

class ToolBar extends StatefulWidget {
  final BoxConstraints constraints;
  final bool isTall;
  const ToolBar({
    Key? key,
    required this.constraints,
    required this.isTall,
  }) : super(key: key);

  @override
  _ToolBarState createState() => _ToolBarState();
}

class _ToolBarState extends State<ToolBar> {
  @override
  Widget build(BuildContext context) {
    TileProvider tileProvider = context.watch<TileProvider>();
    ConfigProvider configProvider = context.watch<ConfigProvider>();
    int gridSize = tileProvider.gridSize;
    double size = 100;
    double padding = 4;
    double height = widget.isTall ? size : widget.constraints.maxHeight * 1;
    double width = widget.isTall ? widget.constraints.maxWidth * 1 : size;

    List<Widget> children = [
      Scores(isTall: widget.isTall),
      // Container(
      //   constraints: const BoxConstraints(maxHeight: 40, maxWidth: 75),
      //   alignment: Alignment.center,
      //   child: BorderedContainer(
      //     spacing: 5,
      //     child: Container(
      //       constraints:
      //           const BoxConstraints(minHeight: 40, minWidth: 75),
      //       child: TextButton(
      //         style: TextButton.styleFrom(
      //             backgroundColor: secondaryColor[700],
      //             shape: RoundedRectangleBorder()),
      //         onPressed: () {
      //           tileProvider.changeGridSize(gridSize == 3 ? 4 : 3);
      //         },
      //         child: Text(
      //           "${gridSize}x$gridSize",
      //           style: TextStyle(color: Colors.white),
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      MyButton(
          label: "${gridSize}x$gridSize",
          onPressed: () {
            tileProvider.changeGridSize(gridSize == 3 ? 4 : 3);
          },
          expanded: false,
          icon: Text(gridSize == 3 ? "4x4" : "3x3")),
      IconButton(
        onPressed: () => configProvider.toggleNumbersVisibility(),
        icon:
            Icon(configProvider.showNumbers ? Icons.pin : Icons.visibility_off),
      ),
      SoundsVibrationsTool(
          isTall: widget.isTall, configProvider: configProvider),
    ];

    return Container(
      height: height,
      width: width,
      // color: secondaryColor,
      child: BorderedContainer(
        child: Container(
          height: height,
          width: width,
          padding: EdgeInsets.all(padding),
          color: secondaryColor,
          child: widget.isTall
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children,
                )
              : Column(
                  // mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: children,
                ),
        ),
      ),
    );
  }
}
