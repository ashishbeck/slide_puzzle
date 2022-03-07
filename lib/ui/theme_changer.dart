import 'package:flutter/material.dart';
import 'package:slide_puzzle/code/audio.dart';

import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/code/store.dart';
import 'package:slide_puzzle/main.dart';
import 'package:slide_puzzle/ui/bordered_container.dart';

class ThemeChanger extends StatelessWidget {
  final Function() onTap;
  const ThemeChanger({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget item(ColorTheme theme) {
      double size = 40;
      return Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(4.0),
        child: BorderedContainer(
          label: "themeswitcher",
          shouldAnimateEntry: false,
          spacing: 4,
          color: theme.buttonShadowColor,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                AudioService.instance.button();
                AudioService.instance.vibrate();
                changeColor(themes.indexOf(theme));
                Storage.instance.changeColor(themes.indexOf(theme));
                mainKey.currentState!.setState(() {});
                onTap();
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: size,
                    height: size,
                    color: theme.secondaryColor,
                  ),
                  ClipPath(
                    clipper: DiagonalClipperShape(),
                    child: Container(
                        width: size, height: size, color: theme.primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: themes.map((e) => item(e)).toList(),
      ),
    );
  }
}

class DiagonalClipperShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;

    double offset = size.width * 0.3;

    var path = Path()
      ..moveTo(0, 0 + offset)
      ..lineTo(width - offset, height)
      ..lineTo(0, height)
      ..lineTo(0, 0 + offset);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
