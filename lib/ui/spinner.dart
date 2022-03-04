import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class Spinner extends StatelessWidget {
  final String? text;
  const Spinner({
    Key? key,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 50,
            width: 50,
            child: const RiveAnimation.asset(
              'assets/rive/icons.riv',
              animations: ["loading"],
            ),
          ),
          SizedBox(
            height: text != null ? 8 : 0,
          ),
          text != null
              ? Text(
                  text!,
                  textAlign: TextAlign.center,
                )
              : Container()
        ],
      ),
    );
  }
}
