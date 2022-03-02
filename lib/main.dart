import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:slide_puzzle/code/auth.dart';
import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/code/store.dart';
import 'package:slide_puzzle/firebase_options.dart';
import 'package:slide_puzzle/screen/app.dart';
import 'package:provider/provider.dart';
import 'package:slide_puzzle/screen/landing.dart';
import 'package:rxdart/rxdart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  Storage.instance.init();
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
        StreamProvider<User?>.value(
            initialData: null, value: AuthService().user),
        StreamProvider<UserData?>.value(
          initialData: null,
          catchError: (_, __) {
            print("error at $__");
          },
          value: AuthService().user!.transform(
                FlatMapStreamTransformer<User?, UserData?>(
                  (firebaseUser) =>
                      DatabaseService.instance.currentUser(firebaseUser!.uid),
                ),
              ),
        ),
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
          brightness: Brightness.dark,
          tooltipTheme: TooltipThemeData(
            textStyle: TextStyle(
              fontFamily: "Glacial",
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: false ? LayoutPage() : LandingPage(),
      ),
    );
  }
}
