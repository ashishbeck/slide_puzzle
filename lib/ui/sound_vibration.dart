import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:slide_puzzle/code/audio.dart';

import 'package:slide_puzzle/code/providers.dart';
import 'package:slide_puzzle/code/store.dart';

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
  Artboard? _audioArtboard;
  SMIInput<bool>? _isAudioVisible;
  Artboard? _vibrationArtboard;
  SMIInput<bool>? _isVibrationVisible;

  @override
  void initState() {
    super.initState();

    rootBundle.load('assets/rive/toolbar.riv').then(
      (data) async {
        final file = RiveFile.import(data);

        final audioArtboard = file.artboardByName("audio");
        final vibrationArtboard = file.artboardByName("vibration");
        var audioController =
            StateMachineController.fromArtboard(audioArtboard!, 'toggle');
        var vibrationController =
            StateMachineController.fromArtboard(vibrationArtboard!, 'toggle');
        if (audioController != null) {
          audioArtboard.addController(audioController);
          _isAudioVisible = audioController.findInput('isVisible');
        }
        if (vibrationController != null) {
          vibrationArtboard.addController(vibrationController);
          _isVibrationVisible = vibrationController.findInput('isVisible');
        }
        setState(() {
          _audioArtboard = audioArtboard;
          _vibrationArtboard = vibrationArtboard;
        });
      },
    );
  }

  _animate(ConfigProvider configProvider) {
    if (_isAudioVisible != null) {
      if (configProvider.muted) {
        _isAudioVisible!.value = false;
      } else {
        _isAudioVisible!.value = true;
      }
    }
    if (_isVibrationVisible != null) {
      if (configProvider.vibrationsOff) {
        _isVibrationVisible!.value = false;
      } else {
        _isVibrationVisible!.value = true;
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
          icon: _audioArtboard == null
              ? Rive(artboard: RuntimeArtboard())
              : Rive(artboard: _audioArtboard!),
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
          icon: _vibrationArtboard == null
              ? Rive(artboard: RuntimeArtboard())
              : Rive(artboard: _vibrationArtboard!),
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
