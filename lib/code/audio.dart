import 'dart:math';

import 'package:flutter/services.dart';
import 'package:slide_puzzle/code/constants.dart';
import 'package:soundpool/soundpool.dart';

class AudioService {
  static final AudioService instance = AudioService._init();
  AudioService._init();
  Soundpool pool = Soundpool.fromOptions(
      // options: const SoundpoolOptions(streamType: StreamType.notification),
      );

  List<int> slideIds = List.generate(slideAudio.length, (index) => 0);
  int dragId = 0;
  int dragFailId = 0;
  int sweepId = 0;
  AudioStreamControl? dragStream;
  bool isMuted = false;
  bool shouldVibrate = true;

  init() async {
    for (var i = 0; i < slideAudio.length; i++) {
      slideIds[i] = await rootBundle
          .load("assets/audio/${slideAudio[i]}")
          .then((ByteData soundData) {
        return pool.load(soundData);
      });
    }
    dragId = await rootBundle
        .load("assets/audio/servo.wav")
        .then((ByteData soundData) {
      return pool.load(soundData);
    });
    dragFailId = await rootBundle
        .load("assets/audio/servo_end.wav")
        .then((ByteData soundData) {
      return pool.load(soundData);
    });
    sweepId = await rootBundle
        .load("assets/audio/powerup_1.wav")
        .then((ByteData soundData) {
      return pool.load(soundData);
    });
  }

  slide(Duration? duration) async {
    if (isMuted) return;
    var rand = Random();
    int id = rand.nextInt(slideAudio.length);
    pool.play(slideIds[id]);
    // var stream = await pool.playWithControls(dragId);
    // stream.setVolume(volume: 0.2);
    // await Future.delayed(Duration(milliseconds: defaultTime));
    // stream.stop();
  }

  drag({starting = true, failed = false}) async {
    if (isMuted) return;
    if (failed) {
      var stream = await pool.playWithControls(dragFailId);
      stream.setVolume(volume: 0.1);
    } else if (starting) {
      dragStream ??= await pool.playWithControls(dragId, repeat: 10);
      dragStream!.setVolume(volume: 0.2);
    } else {
      dragStream?.stop();
      dragStream = null;
    }
  }

  shuffle() async {
    if (isMuted) return;
    var stream = await pool.playWithControls(sweepId);
    stream.setVolume(volume: 0.2);
    await Future.delayed(Duration(milliseconds: defaultTime * 3));
    stream.stop();
  }

  vibrate() async {
    if (shouldVibrate) HapticFeedback.lightImpact();
  }
}
