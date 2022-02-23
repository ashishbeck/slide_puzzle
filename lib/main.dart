import 'dart:math';

import 'package:flutter/material.dart';
import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/screen/app.dart';
import 'package:provider/provider.dart';
import 'package:slide_puzzle/screen/landing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // flutter build web --release --base-href="/slide_puzzle_release/"
  @override
  Widget build(BuildContext context) {
    // int gridSize = 3;
    // int totalTiles = pow(gridSize, 2).toInt();
    // List<TilesModel> list = List.generate(totalTiles, (index) {
    //   Coordinates coordinates = Coordinates(
    //       row: (index / gridSize).floor(), column: index % gridSize);
    //   return TilesModel(
    //     defaultIndex: index,
    //     currentIndex: index,
    //     coordinates: coordinates,
    //     isWhite: index == totalTiles - 1,
    //   );
    // });
    return MultiProvider(
      providers: [
        // Provider<List<TilesModel>>.value(
        //   value: list,
        // ),
        ChangeNotifierProvider(create: (context) => TileProvider()),
        ChangeNotifierProvider(create: (context) => TweenProvider()),
        ChangeNotifierProvider(create: (context) => ConfigProvider()),
        ChangeNotifierProvider(create: (context) => ScoreProvider()),
        Provider<TweenModel>(
          create: (_) => TweenModel(
              // tweenTopOffset: 0,
              // tweenLeftOffset: 0,
              // isRow: true,
              // axis: Axis.horizontal,
              ),
        ),
      ],
      child: MaterialApp(
        title: 'Slide Puzzle',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: "Arcade",
          colorSchemeSeed: primaryColor,
          // primarySwatch: primaryColor,
          brightness: Brightness.dark,
        ),
        home: LandingPage(),
      ),
    );
  }
}
