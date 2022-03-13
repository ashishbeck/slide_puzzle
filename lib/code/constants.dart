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
    Color.fromARGB(255, 76, 175, 80),
    Color.fromARGB(255, 35, 35, 35),
    Color.fromARGB(255, 41, 100, 43),
  ),
  const ColorTheme(
    Color.fromARGB(255, 30, 131, 214),
    Color.fromARGB(255, 228, 101, 143),
    Color.fromARGB(255, 24, 109, 179),
  ),
  const ColorTheme(
    Color.fromARGB(255, 49, 49, 49),
    Color.fromARGB(255, 145, 145, 145),
    Color.fromARGB(255, 12, 12, 12),
  ),
];
void changeColor(int index) {
  primaryColor = themes[index].primaryColor;
  secondaryColor = themes[index].secondaryColor;
  buttonShadowColor = themes[index].buttonShadowColor;
}

String appLink = "https://ashishbeck.github.io/slide_puzzle/";

MySnackbar(String text, BuildContext context) => SnackBar(
      content: Text(
        text,
        style: const TextStyle(
            fontSize: 24, color: Colors.white, fontFamily: "Arcade"),
        textAlign: TextAlign.center,
      ),
      backgroundColor: secondaryColor,
      duration: const Duration(milliseconds: 1000),
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.5,
          left: 24,
          right: 24),
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.horizontal,
    );
