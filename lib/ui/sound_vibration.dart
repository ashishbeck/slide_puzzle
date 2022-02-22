import 'package:flutter/material.dart';

import 'package:slide_puzzle/code/providers.dart';

class SoundsVibrationsTool extends StatelessWidget {
  final bool isTall;
  final ConfigProvider configProvider;
  const SoundsVibrationsTool({
    Key? key,
    required this.isTall,
    required this.configProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      IconButton(
        icon: Icon(configProvider.muted ? Icons.volume_off : Icons.volume_up),
        onPressed: configProvider.toggleSound,
      ),
      // isTall ? Divider() : VerticalDivider(),
      IconButton(
        icon: Icon(configProvider.vibrationsOff
            ? Icons.disabled_by_default
            : Icons.vibration),
        onPressed: configProvider.toggleVibration,
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
