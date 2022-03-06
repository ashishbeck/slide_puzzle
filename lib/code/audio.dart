import 'dart:math';
import 'package:flutter/services.dart';
import 'package:slide_puzzle/code/store.dart';
import 'package:soundpool/soundpool.dart';

class AudioService {
  static final AudioService instance = AudioService._init();
  AudioService._init();
  Soundpool pool = Soundpool.fromOptions(
      // options: const SoundpoolOptions(streamType: StreamType.notification),
      );

  List<int> slideIds = List.generate(5, (index) => 0);
  int shuffleId = 0;
  int entryId = 0;
  int elementEntryId = 0;
  int entryBgId = 0;
  int tilesId = 0;
  int tilesExitId = 0;
  int buttonId = 0;
  int buttonDownId = 0;
  int buttonUpId = 0;
  int bubbleId = 0;
  AudioStreamControl? dragStream;
  bool isMuted = !Storage.instance.sounds;
  bool shouldVibrate = Storage.instance.vibrations;

  Future<void> init() async {
    for (var i = 0; i < 5; i++) {
      slideIds[i] = await rootBundle
          .load("assets/audio/slide_$i.wav")
          .then((ByteData soundData) {
        return pool.load(soundData);
      });
    }
    shuffleId = await rootBundle
        .load("assets/audio/shuffle.wav")
        .then((ByteData soundData) {
      return pool.load(soundData);
    });
    entryId = await rootBundle
        .load("assets/audio/entry.wav")
        .then((ByteData soundData) {
      return pool.load(soundData);
    });
    elementEntryId = await rootBundle
        .load("assets/audio/whoosh.wav")
        .then((ByteData soundData) {
      return pool.load(soundData);
    });
    entryBgId = await rootBundle
        .load("assets/audio/entry_bg.wav")
        .then((ByteData soundData) {
      return pool.load(soundData);
    });
    tilesId = await rootBundle
        .load("assets/audio/tiles.wav")
        .then((ByteData soundData) {
      return pool.load(soundData);
    });
    tilesExitId = await rootBundle
        .load("assets/audio/tiles_exit.wav")
        .then((ByteData soundData) {
      return pool.load(soundData);
    });
    buttonId = await rootBundle
        .load("assets/audio/button.wav")
        .then((ByteData soundData) {
      return pool.load(soundData);
    });
    buttonDownId = await rootBundle
        .load("assets/audio/button_down.wav")
        .then((ByteData soundData) {
      return pool.load(soundData);
    });
    buttonUpId = await rootBundle
        .load("assets/audio/button_up.wav")
        .then((ByteData soundData) {
      return pool.load(soundData);
    });
    bubbleId = await rootBundle
        .load("assets/audio/bubbles.wav")
        .then((ByteData soundData) {
      return pool.load(soundData);
    });
  }

  slide(Duration? duration) async {
    if (isMuted) return;
    var rand = Random();
    int id = rand.nextInt(5);
    pool.play(slideIds[id]);
    // var stream = await pool.playWithControls(dragId);
    // stream.setVolume(volume: 0.2);
    // await Future.delayed(Duration(milliseconds: defaultTime));
    // stream.stop();
  }

  shuffle() async {
    if (isMuted) return;
    // await Future.delayed(Duration(milliseconds: 400));
    var stream = await pool.playWithControls(shuffleId);
    // stream.setVolume(volume: 0.2);
    // await Future.delayed(Duration(milliseconds: defaultTime * 3));
    // stream.stop();
  }

  entry() {
    if (isMuted) return;
    pool.play(entryId);
  }

  elementEntry() async {
    if (isMuted) return;
    await Future.delayed(Duration(milliseconds: 200));
    var stream = await pool.playWithControls(elementEntryId);
    var second = await pool.playWithControls(entryBgId);
    stream.setVolume(volume: 0.2);
    second.setVolume(volume: 0.2);
  }

  tiles() {
    if (isMuted) return;
    pool.play(tilesId);
  }

  tilesExit() {
    if (isMuted) return;
    pool.play(tilesExitId);
  }

  button() {
    if (isMuted) return;
    pool.play(buttonId);
  }

  buttonDown() {
    if (isMuted) return;
    pool.play(buttonDownId);
  }

  buttonUp() {
    if (isMuted) return;
    pool.play(buttonUpId);
  }

  bubbles() async {
    if (isMuted) return;
    var stream = await pool.playWithControls(bubbleId);
    stream.setVolume(volume: 0.6);
  }

  vibrate() async {
    if (shouldVibrate) HapticFeedback.lightImpact();
  }
}
