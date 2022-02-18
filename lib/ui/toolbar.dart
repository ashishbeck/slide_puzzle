import 'package:flutter/material.dart';
import 'package:slide_puzzle/code/providers.dart';
import 'package:provider/provider.dart';
import 'package:slide_puzzle/ui/scores.dart';

class ToolBar extends StatefulWidget {
  const ToolBar({Key? key}) : super(key: key);

  @override
  _ToolBarState createState() => _ToolBarState();
}

class _ToolBarState extends State<ToolBar> {
  @override
  Widget build(BuildContext context) {
    TileProvider tileProvider = context.watch<TileProvider>();
    ConfigProvider configProvider = context.watch<ConfigProvider>();
    int gridSize = tileProvider.gridSize;

    return Container(
      child: Row(children: [
        const Scores(),
        TextButton(
          onPressed: () {
            tileProvider.changeGridSize(gridSize == 3 ? 4 : 3);
          },
          child: Text("${gridSize}x$gridSize"),
        ),
        IconButton(
            onPressed: () => configProvider.toggleNumbersVisibility(),
            icon: Icon(configProvider.showNumbers
                ? Icons.visibility_off
                : Icons.visibility))
      ]),
    );
  }
}
