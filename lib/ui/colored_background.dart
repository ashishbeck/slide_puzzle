import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/code/providers.dart';
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

  _calculatePercentage(List<TilesModel> tileList) {
    if (tileList.isEmpty) return 0;
    int total = tileList.length;
    int done = tileList
        .where((element) => element.currentIndex == element.defaultIndex)
        .length;
    return done / total;
  }

  @override
  Widget build(BuildContext context) {
    TileProvider tileProvider = context.watch<TileProvider>();
    ConfigProvider configProvider = context.watch<ConfigProvider>();
    List<TilesModel> tileList = tileProvider.getTileList;
    double perc = _calculatePercentage(tileList);

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
            // child: widget.child,
          ),
        ),
        widget.child
      ],
    );
  }
}
