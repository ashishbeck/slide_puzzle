import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:slide_puzzle/code/auth.dart';
import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/screen/app.dart';
import 'package:slide_puzzle/ui/3d_transform.dart';
import 'package:slide_puzzle/ui/Scoreboard.dart';
import 'package:slide_puzzle/ui/bordered_container.dart';
import 'package:slide_puzzle/ui/dialog.dart';
import 'package:slide_puzzle/ui/sound_vibration.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:slide_puzzle/ui/button.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  final FocusNode _focusNode = FocusNode();
  String appName = "Retro Slide Puzzle";
  String packageName = "";
  String version = "";
  String buildNumber = "";
  bool isHovering1 = false;
  bool isHovering2 = false;
  List<String> usernames = [];

  List<String> _generateUserName({int total = 5}) {
    List<String> usernames = generateWordPairs(maxSyllables: 4)
        .take(total)
        .map((e) => e.asPascalCase)
        .toList();
    return usernames;
  }

  _updateUserName(String? newUsername) {
    UserData? userData = context.read<UserData?>();
    if (newUsername == null || newUsername == userData!.username) return;
    DatabaseService.instance
        .updateUserData(userData.copyWith(username: newUsername));
    setState(() {
      usernames = _generateUserName();
    });
  }

  _getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    setState(() {});
  }

  _launch(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunch(uri.toString())) {
      launch(uri.toString());
    }
  }

  _onPressed() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // if (animationController.isCompleted) {
    //   animationController.reverse();
    // } else {
    setState(() {
      // disableButton = true;
    });
    animationController.forward().then(
          (value) => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LayoutPage(),
            ),
          ),
        );
  }

  _handleKeyEvent(RawKeyEvent event) {
    if (event.runtimeType == RawKeyDownEvent &&
        event.data.logicalKey == LogicalKeyboardKey.enter &&
        !animationController.isAnimating) {
      _onPressed();
    }
  }

  @override
  void initState() {
    super.initState();
    _getPackageInfo();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2500),
        vsync: this,
        value: 0,
        lowerBound: 0,
        upperBound: 1);

    User? user = context.read<User?>();
    if (user == null) AuthService().signInAnonymously();
    TileProvider tileProvider = context.read<TileProvider>();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      tileProvider.updateImages(context);
    });
    usernames = _generateUserName();
    // DatabaseService.instance.fetchLeaderBoards();
    // DatabaseService.instance.submitDummyCommunityScores();
    // generateWordPairs(maxSyllables: 4).take(15).forEach(print);
    // generateWordPairs(maxSyllables: 4).take(1).forEach((e) {
    //   print(e);
    //   print(e.asCamelCase);
    //   print(e.asLowerCase);
    //   print(e.asPascalCase);
    //   print(e.asSnakeCase);
    //   print(e.asUpperCase);
    //   print(e.asString);
    // });
  }

  @override
  void dispose() {
    animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserData? userData = context.watch<UserData?>();
    if (userData != null) {
      print("user found: ${userData.toMap()}");
    } else {
      print("no user found");
    }

    Widget button() => MyButton(
          label: "Enter",
          tooltip: "",
          // labelStyle: TextStyle(color: secondaryColor),
          shouldAnimateEntry: false,
          onPressed: _onPressed,
          expanded: false,
        );

    Widget info() => const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "This game can be played with keyboard arrow keys, screen tap, click, drag n drop and flick to move any number of tiles "
            "possible.",
            style: TextStyle(fontFamily: "Glacial", color: Colors.white),
            textAlign: TextAlign.center,
          ),
        );

    Widget usernameWidget() {
      return Text.rich(
        TextSpan(text: "Your username is ", children: [
          WidgetSpan(
            baseline: TextBaseline.alphabetic,
            child: PopupMenuButton<String>(
              child: Text(
                userData!.username,
                style: TextStyle(
                  color: primaryColor,
                  fontFamily: "Glacial",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              tooltip: "Change username",
              color: Colors.white,
              shape: const RoundedRectangleBorder(),
              itemBuilder: (context) {
                // PopupMenuItem(
                //   child: Text(userData.username),
                //   value: userData.username,
                // ),
                return usernames
                    .map((e) => PopupMenuItem<String>(
                          child: Text(
                            e,
                            style: TextStyle(
                              fontFamily: "Glacial",
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          value: e,
                        ))
                    .toList();
              },
              onSelected: _updateUserName,
              onCanceled: () {
                setState(() {
                  usernames = _generateUserName();
                });
              },
            ),
          ),
          // WidgetSpan(
          //   child: MouseRegion(
          //     cursor: SystemMouseCursors.click,
          //     child: GestureDetector(
          //       child: Icon(Icons.compare_arrows),
          //       onTap: _generateUserName,
          //     ),
          //   ),
          // ),
        ]),
        style: const TextStyle(fontFamily: "Glacial", fontSize: 24),
        textAlign: TextAlign.right,
      );
    }

    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: secondaryColor,
        body: ScaleTransition(
          scale: Tween<double>(begin: 1, end: 350).animate(CurvedAnimation(
              parent: animationController, curve: Curves.easeInQuart)),
          child: RotationTransition(
            turns: Tween<double>(begin: 0, end: 0.25).animate(CurvedAnimation(
                parent: animationController, curve: Curves.easeIn)),
            child: LayoutBuilder(builder: (context, constraints) {
              double maxWidth = constraints.maxWidth;
              double maxHeight = constraints.maxHeight;
              return Container(
                height: maxHeight,
                width: maxWidth,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      // secondaryColor[400]!,
                      secondaryColor,
                      secondaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          appName,
                          style: Theme.of(context).textTheme.headline5,
                          textAlign: TextAlign.center,
                        ),
                        animationController.isAnimating
                            ? IgnorePointer(
                                child: button(),
                              )
                            : button(),
                        Text(
                          appName,
                          style: Theme.of(context)
                              .textTheme
                              .headline5!
                              .copyWith(color: secondaryColor),
                          textAlign: TextAlign.center,
                        ),
                        // userData != null
                        //     ? ScoreBoard(
                        //         gridSize: 3,
                        //         // currentMove: 0,
                        //         // currentTime: 0,
                        //         userData: userData,
                        //         child: Container(),
                        //       )
                        //     : Container(),
                      ],
                    )),
                    userData != null
                        ? Align(
                            alignment: Alignment(0, 0.2),
                            // top: maxHeight * 0.55,
                            // left: 0,
                            // right: 0,
                            child: usernameWidget(),
                          )
                        : Container(),
                    const Align(
                      alignment: Alignment(0.95, -0.98),
                      child: SoundsVibrationsTool(isTall: false),
                    ),
                    Align(
                      alignment: Alignment(0, 0.8),
                      child: Text.rich(
                        TextSpan(text: "A project by ", children: [
                          WidgetSpan(
                            child: MouseRegion(
                              onEnter: (event) =>
                                  setState(() => isHovering1 = true),
                              onExit: (event) =>
                                  setState(() => isHovering1 = false),
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () =>
                                    _launch('https://linktr.ee/ashishbeck'),
                                child: Text(
                                  "Ashish Beck",
                                  style: TextStyle(
                                      color: isHovering1
                                          ? Colors.white
                                          : primaryColor),
                                ),
                              ),
                            ),
                          ),
                          // TextSpan(
                          //     text: "\nwith design help from ",
                          //     style: Theme.of(context)
                          //         .textTheme
                          //         .labelSmall!
                          //         .copyWith(
                          //             decorationStyle: TextDecorationStyle.wavy,
                          //             decorationThickness: 4,
                          //             decoration: TextDecoration.lineThrough)),
                          // WidgetSpan(
                          //   child: MouseRegion(
                          //     onEnter: (event) =>
                          //         setState(() => isHovering2 = true),
                          //     onExit: (event) =>
                          //         setState(() => isHovering2 = false),
                          //     cursor: SystemMouseCursors.click,
                          //     child: GestureDetector(
                          //       onTap: () =>
                          //           _launch('https://linktr.ee/sushobhan'),
                          //       child: Text(
                          //         "Sushobhan Parida",
                          //         style: Theme.of(context)
                          //             .textTheme
                          //             .labelSmall!
                          //             .copyWith(
                          //                 decorationStyle:
                          //                     TextDecorationStyle.wavy,
                          //                 decorationThickness: 4,
                          //                 decoration:
                          //                     TextDecoration.lineThrough,
                          //                 color: isHovering2
                          //                     ? Colors.white
                          //                     : primaryColor),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        "v${version}",
                        style: Theme.of(context).textTheme.caption,
                      ),
                    )
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
