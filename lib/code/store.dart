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
  int _colorTheme = 0;
  int get colorTheme => _colorTheme;
  bool _showNameChange = true;
  bool get showNameChange => _showNameChange;
  bool _showPracticeMode = true;
  bool get showPracticeMode => _showPracticeMode;

  init() {
    _sounds = box.read<bool>("sounds") ?? true;
    AudioService.instance.isMuted = !_sounds;
    _vibrations = box.read<bool>("vibrations") ?? true;
    AudioService.instance.shouldVibrate = _vibrations;
    _colorTheme = box.read<int>("color") ?? 0;
    _showNameChange = box.read<bool>("showNameChange") ?? true;
    _showPracticeMode = true;
    // _showPracticeMode = box.read<bool>("showPracticeMode") ?? true;
  }

  toggleSounds() {
    _sounds = !_sounds;
    box.write("sounds", _sounds);
  }

  toggleVibrations() {
    _vibrations = !_vibrations;
    box.write("vibrations", _vibrations);
  }

  changeColor(int index) {
    _colorTheme = index;
    box.write("color", _colorTheme);
  }

  seenNameChange() {
    _showNameChange = false;
    box.write("showNameChange", false);
  }

  seenPracticeMode() {
    _showPracticeMode = false;
    box.write("showPracticeMode", false);
  }
}
