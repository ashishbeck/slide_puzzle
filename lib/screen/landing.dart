import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:slide_puzzle/code/auth.dart';
import 'package:slide_puzzle/code/constants.dart';
import 'package:slide_puzzle/code/models.dart';
import 'package:slide_puzzle/screen/app.dart';
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
  String appName = "Slide Puzzle";
  String packageName = "";
  String version = "";
  String buildNumber = "";
  bool isHovering1 = false;
  bool isHovering2 = false;

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

  _authenticateUser() async {}

  @override
  void initState() {
    super.initState();
    _getPackageInfo();
    animationController = AnimationController(
        duration: Duration(milliseconds: 2500),
        vsync: this,
        value: 0,
        lowerBound: 0,
        upperBound: 1);

    User? user = context.read<User?>();
    if (user == null) AuthService().signInAnonymously();
  }

  @override
  Widget build(BuildContext context) {
    UserData? userData = context.watch<UserData?>();
    if (userData != null) {
      print("user found: ${userData.toMap()}");
    } else {
      print("no user found");
    }
    return Scaffold(
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
                      ),
                      MyButton(
                        label: "Enter",
                        // labelStyle: TextStyle(color: secondaryColor),
                        shouldAnimateEntry: false,
                        onPressed: () async {
                          await Future.delayed(Duration(milliseconds: 200));
                          if (animationController.isCompleted) {
                            animationController.reverse();
                          } else {
                            animationController.forward().then(
                                  (value) => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LayoutPage(),
                                    ),
                                  ),
                                );
                          }
                        },
                        expanded: false,
                      ),
                      Text(
                        appName,
                        style: Theme.of(context)
                            .textTheme
                            .headline5!
                            .copyWith(color: secondaryColor),
                      ),
                    ],
                  )),
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
                        TextSpan(
                            text: "\nwith design help from ",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                                    decorationStyle: TextDecorationStyle.wavy,
                                    decorationThickness: 4,
                                    decoration: TextDecoration.lineThrough)),
                        WidgetSpan(
                          child: MouseRegion(
                            onEnter: (event) =>
                                setState(() => isHovering2 = true),
                            onExit: (event) =>
                                setState(() => isHovering2 = false),
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () =>
                                  _launch('https://linktr.ee/sushobhan'),
                              child: Text(
                                "Sushobhan Parida",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .copyWith(
                                        decorationStyle:
                                            TextDecorationStyle.wavy,
                                        decorationThickness: 4,
                                        decoration: TextDecoration.lineThrough,
                                        color: isHovering2
                                            ? Colors.white
                                            : primaryColor),
                              ),
                            ),
                          ),
                        ),
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
    );
  }
}
