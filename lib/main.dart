import 'dart:math';

import 'package:flutter/material.dart';
import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/screen/app.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    int gridSize = 4;
    int totalTiles = pow(gridSize, 2).toInt();
    List<TilesModel> list = List.generate(
        totalTiles,
        (index) => TilesModel(
            defaultIndex: index,
            currentIndex: index,
            isWhite: index == totalTiles - 1));
    return MultiProvider(
      providers: [
        Provider<List<TilesModel>>.value(
          value: list,
        ),
        ChangeNotifierProvider(create: (context) => TileProvider()),
        ChangeNotifierProvider(create: (context) => TweenProvider()),
        ChangeNotifierProvider(create: (context) => ConfigProvider()),
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
          primarySwatch: Colors.blue,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)))),
          ),
        ),
        home: LayoutPage(),
      ),
    );
  }
}
