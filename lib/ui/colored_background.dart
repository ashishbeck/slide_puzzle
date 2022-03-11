import 'dart:async';

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

class _ColoredBackgroundState extends State<ColoredBackground>
    with SingleTickerProviderStateMixin {
  // late AnimationController animationController;
  Duration duration = const Duration(milliseconds: 3000);
  Duration flipDuration = const Duration(milliseconds: 500);
  Timer? timer;
  bool isLoaded = false;

  double _calculatePercentage(List<TilesModel> tileList) {
    if (tileList.isEmpty) return 1;
    int total = tileList.length;
    int done = tileList
        .where((element) => element.currentIndex == element.defaultIndex)
        .length;
    return (done / total).toDouble();
  }

  // _animate() {
  //   timer = Timer.periodic(const Duration(seconds: 2), (timer) {
  //     print("running");
  //     if (mounted) {
  //       animationController.forward().then((value) {
  //         if (mounted) {
  //           animationController.value = 0;
  //         }
  //       });
  //     }
  //   });
  // }

  _loadSquares() async {
    if (isLoaded) return;
    await Future.delayed(const Duration(milliseconds: 2000));
    setState(() {
      isLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    // animationController = AnimationController(vsync: this, duration: duration);
    // _animate();
  }

  @override
  void dispose() {
    // animationController.dispose();
    if (timer != null) timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TileProvider tileProvider = context.watch<TileProvider>();
    ConfigProvider configProvider = context.watch<ConfigProvider>();
    List<TilesModel> tileList = tileProvider.getTileList;
    double perc = _calculatePercentage(tileList);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double boxSize = 100;
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
          onLoaded: _loadSquares,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              // color: secondaryColor.withOpacity((1 - perc) * 0.5),
              gradient: RadialGradient(
                colors: [
                  Colors.transparent,
                  primaryColor.withOpacity((1 - perc) * 0.5),
                ],
                tileMode: TileMode.mirror,
                // stops: [
                //   0.2,
                //   0.9,
                // ],
                radius: 1 - perc,
              ),
            ),
            // child: ExampleFunvasWidget(),
            child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                curve: Curves.ease,
                duration: const Duration(milliseconds: 2000),
                builder: (BuildContext context, double opacity, Widget? child) {
                  return Opacity(
                    opacity: isLoaded ? 1 : opacity,
                    child: Stack(
                      children: [
                        for (var i = 0; i < totalHorizontalBoxes; i++) ...{
                          for (var j = 0; j < totalVerticalBoxes; j++) ...{
                            BackgroundBox(
                              size: boxSize,
                              offset: Offset(i.toDouble(), j.toDouble()),
                              configProvider: configProvider,
                              // animationController: animationController,
                            ),
                          },
                        }
                      ],
                    ),
                  );
                }),
          ),
        ),
        widget.child
      ],
    );
  }
}
