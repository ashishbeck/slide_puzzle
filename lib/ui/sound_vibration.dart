import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slide_puzzle/code/audio.dart';

import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/code/store.dart';

class SoundsVibrationsTool extends StatelessWidget {
  final bool isTall;
  const SoundsVibrationsTool({
    Key? key,
    required this.isTall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ConfigProvider configProvider = context.watch<ConfigProvider>();
    List<Widget> children = [
      Expanded(
        child: IconButton(
          tooltip: "Toggle sounds",
          icon: Icon(configProvider.muted ? Icons.volume_off : Icons.volume_up),
          onPressed: () {
            configProvider.toggleSound();
            AudioService.instance.vibrate();
          },
        ),
      ),
      // isTall ? Divider() : VerticalDivider(),
      Expanded(
        child: IconButton(
          tooltip: "Toggle vibrations",
          icon: Icon(configProvider.vibrationsOff
              ? Icons.disabled_by_default
              : Icons.vibration),
          onPressed: () {
            configProvider.toggleVibration();
            AudioService.instance.vibrate();
          },
        ),
      ),
    ];

    return Container(
      child: IntrinsicHeight(
        child: IntrinsicWidth(
          child: isTall
              ? Column(
                  children: children,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                ),
        ),
      ),
    );
  }
}
