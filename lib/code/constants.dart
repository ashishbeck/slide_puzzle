import 'package:flutter/material.dart';
import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/code/store.dart';

int defaultTime = 500;
int defaultEntryTime = 1000;
int defaultSidebarTime = 4000;
Curve defaultCurve = Curves.easeOutBack;
double buttonHeight = 60;

ColorTheme defaultTheme = themes[Storage.instance.colorTheme];
Color primaryColor = defaultTheme.primaryColor;
Color secondaryColor = defaultTheme.secondaryColor;
Color buttonShadowColor = defaultTheme.buttonShadowColor;
List<ColorTheme> themes = [
  // const ColorTheme(
  //   Color(0xffFFD459),
  //   Color(0xffB6083D),
  //   Color(0xff856712),
  // ),
  const ColorTheme(
    Color.fromARGB(255, 33, 150, 243),
    Color.fromARGB(255, 233, 59, 117),
    Color.fromARGB(255, 24, 109, 179),
  ),
  const ColorTheme(
    Color.fromARGB(255, 76, 175, 80),
    Color.fromARGB(255, 35, 35, 35),
    Color.fromARGB(255, 41, 100, 43),
  ),
  const ColorTheme(
    Color(0xff856712),
    Color.fromARGB(255, 33, 19, 13),
    Color.fromARGB(255, 99, 76, 13),
  ),
];
void changeColor(int index) {
  primaryColor = themes[index].primaryColor;
  secondaryColor = themes[index].secondaryColor;
  buttonShadowColor = themes[index].buttonShadowColor;
}

List<String> slideAudio = [
  "amb_electricarc_small_b_01.wav",
  "amb_electricarc_small_b_02.wav",
  "amb_electricarc_small_b_03.wav",
  "amb_electricarc_small_b_04.wav",
];

String appLink = "https://n-puzzle-solver-1.web.app/";
