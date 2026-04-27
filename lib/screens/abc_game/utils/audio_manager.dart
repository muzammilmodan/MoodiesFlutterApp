import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  double _currentVolume = 1.0; // Default volume

  AudioManager._internal();

  bool get isPlaying => _isPlaying;

  Future<void> playAudio({double volume = 1.0}) async {
    if (!_isPlaying) {
      _currentVolume = volume; // Store the current volume
      await _player.setVolume(_currentVolume);
      await _player.setSource(AssetSource('abcgames/audio/bg_.mp4'));
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.resume();
      _isPlaying = true;
    }
  }

  Future<void> pauseAudio() async {
    if (_isPlaying) {
      await _player.pause();
      _isPlaying = false;
    }
  }

  Future<void> setVolume(double volume) async {
    _currentVolume = volume; // Update the current volume
    await _player.setVolume(volume);
  }

  Future<void> resetVolume() async {
    _currentVolume = 1.0; // Reset volume to default (1.0)
    await _player.setVolume(_currentVolume);
  }
  Future<void>dispose()async{
    await _player.dispose();
  }
}
