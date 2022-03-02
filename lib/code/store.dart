import 'package:get_storage/get_storage.dart';
import 'package:slide_puzzle/code/audio.dart';

class Storage {
  static final Storage instance = Storage._init();
  Storage._init();
  final box = GetStorage();

  bool _sounds = true;
  bool get sounds => _sounds;
  bool _vibrations = true;
  bool get vibrations => _vibrations;

  init() {
    _sounds = box.read<bool>("sounds") ?? true;
    AudioService.instance.isMuted = !_sounds;
    _vibrations = box.read<bool>("vibrations") ?? true;
    AudioService.instance.shouldVibrate = _vibrations;
  }

  toggleSounds() {
    _sounds = !_sounds;
    box.write("sounds", _sounds);
  }

  toggleVibrations() {
    _vibrations = !_vibrations;
    box.write("vibrations", _vibrations);
  }
}
