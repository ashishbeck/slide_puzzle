import 'package:flutter/material.dart';

import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/code/providers.dart';

class MyMouseRegion extends StatefulWidget {
  final Widget child;
  final ConfigProvider configProvider;
  final TilesModel thisTile;
  const MyMouseRegion({
    Key? key,
    required this.child,
    required this.configProvider,
    required this.thisTile,
  }) : super(key: key);

  @override
  State<MyMouseRegion> createState() => _MyMouseRegionState();
}

class _MyMouseRegionState extends State<MyMouseRegion>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  bool isHovering = false;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        lowerBound: 0.85,
        upperBound: 1);
    animationController.value = 1;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.configProvider.gamestate == GameState.started
          ? widget.thisTile.isWhite
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) {
        if (widget.configProvider.gamestate == GameState.started) {
          animationController.reverse();
        }
      },
      onExit: (_) {
        if (widget.configProvider.gamestate == GameState.started) {
          animationController.forward();
        }
      },
      child: FadeTransition(
        // duration: const Duration(milliseconds: 200),
        opacity: animationController,
        child: widget.child,
      ),
    );
  }
}
