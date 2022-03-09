import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/ui/background.dart';
import 'package:slide_puzzle/ui/delayed_loader.dart';

class ColoredBackground extends StatefulWidget {
  final Widget child;
  const ColoredBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ColoredBackground> createState() => _ColoredBackgroundState();
}

class _ColoredBackgroundState extends State<ColoredBackground> {
  Duration duration = const Duration(milliseconds: 3000);

  double _calculatePercentage(List<TilesModel> tileList) {
    if (tileList.isEmpty) return 1;
    int total = tileList.length;
    int done = tileList
        .where((element) => element.currentIndex == element.defaultIndex)
        .length;
    return (done / total).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    TileProvider tileProvider = context.watch<TileProvider>();
    ConfigProvider configProvider = context.watch<ConfigProvider>();
    List<TilesModel> tileList = tileProvider.getTileList;
    double perc = _calculatePercentage(tileList);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double boxSize = 200;
    int totalHorizontalBoxes = (width / (boxSize - 10)).ceil();
    int totalVerticalBoxes = (height / (boxSize - 10)).ceil();

    return Stack(
      alignment: Alignment.center,
      children: [
        DelayedLoader(
          duration: duration,
          configProvider: configProvider,
          label: "puzzlebg",
          // preload: true,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              // color: secondaryColor.withOpacity((1 - perc) * 0.5),
              gradient: RadialGradient(
                colors: [
                  Colors.transparent,
                  secondaryColor.withOpacity((1 - perc) * 0.5),
                ],
              ),
            ),
            // child: ExampleFunvasWidget(),
            child: Stack(
              children: [
                for (var i = 0; i < totalHorizontalBoxes; i++) ...{
                  for (var j = 0; j < totalVerticalBoxes; j++) ...{
                    BackgroundBox(
                      size: boxSize,
                      offset: Offset(i.toDouble(), j.toDouble()),
                    ),
                  },
                }
              ],
            ),
          ),
        ),
        widget.child
      ],
    );
  }
}
