import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class Spinner extends StatelessWidget {
  const Spinner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 50,
      width: 50,
      child: RiveAnimation.asset(
        'assets/rive/icons.riv',
        animations: ["loading"],
      ),
    );
  }
}
