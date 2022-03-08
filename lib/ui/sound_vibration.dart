import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:slide_puzzle/code/audio.dart';

import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/code/store.dart';
import 'package:slide_puzzle/ui/rive_icons.dart';

class SoundsVibrationsTool extends StatefulWidget {
  final bool isTall;
  const SoundsVibrationsTool({
    Key? key,
    required this.isTall,
  }) : super(key: key);

  @override
  State<SoundsVibrationsTool> createState() => _SoundsVibrationsToolState();
}

class _SoundsVibrationsToolState extends State<SoundsVibrationsTool> {
  final riveInstance = RiveIcons.instance;
  // Artboard? _audioArtboard;
  // SMIInput<bool>? _isAudioVisible;
  // Artboard? _vibrationArtboard;
  // SMIInput<bool>? _isVibrationVisible;

  // @override
  // void initState() {
  //   super.initState();

  //   rootBundle.load('assets/rive/toolbar.riv').then(
  //     (data) async {
  //       final file = RiveFile.import(data);

  //       final audioArtboard = file.artboardByName("audio");
  //       final vibrationArtboard = file.artboardByName("vibration");
  //       var audioController =
  //           StateMachineController.fromArtboard(audioArtboard!, 'toggle');
  //       var vibrationController =
  //           StateMachineController.fromArtboard(vibrationArtboard!, 'toggle');
  //       if (audioController != null) {
  //         audioArtboard.addController(audioController);
  //         _isAudioVisible = audioController.findInput('isVisible');
  //       }
  //       if (vibrationController != null) {
  //         vibrationArtboard.addController(vibrationController);
  //         _isVibrationVisible = vibrationController.findInput('isVisible');
  //       }
  //       setState(() {
  //         _audioArtboard = audioArtboard;
  //         _vibrationArtboard = vibrationArtboard;
  //       });
  //     },
  //   );
  // }

  _animate(ConfigProvider configProvider) {
    if (riveInstance.isAudioVisible != null) {
      if (configProvider.muted) {
        riveInstance.isAudioVisible!.value = false;
      } else {
        riveInstance.isAudioVisible!.value = true;
      }
    }
    if (riveInstance.isVibrationVisible != null) {
      if (configProvider.vibrationsOff) {
        riveInstance.isVibrationVisible!.value = false;
      } else {
        riveInstance.isVibrationVisible!.value = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ConfigProvider configProvider = context.watch<ConfigProvider>();
    _animate(configProvider);
    List<Widget> children = [
      Expanded(
        child: IconButton(
          tooltip: "Toggle sounds",
          icon: riveInstance.audioArtboard == null
              ? Rive(artboard: RuntimeArtboard())
              : Rive(artboard: riveInstance.audioArtboard!),
          // icon: Icon(configProvider.muted ? Icons.volume_off : Icons.volume_up),
          onPressed: () {
            configProvider.toggleSound();
            AudioService.instance.button();
            AudioService.instance.vibrate();
          },
        ),
      ),
      // isTall ? Divider() : VerticalDivider(),
      Expanded(
        child: IconButton(
          tooltip: "Toggle vibrations",
          icon: riveInstance.vibrationArtboard == null
              ? Rive(artboard: RuntimeArtboard())
              : Rive(artboard: riveInstance.vibrationArtboard!),
          onPressed: () {
            configProvider.toggleVibration();
            AudioService.instance.button();
            AudioService.instance.vibrate();
          },
        ),
      ),
    ];

    return Container(
      child: IntrinsicHeight(
        child: IntrinsicWidth(
          child: widget.isTall
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
