import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:audioplayers/audioplayers.dart';

class RingtoneService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> start() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('alert.mp3')); // 🔥 same sound
  }

  static Future<void> stop() async {
    await _player.stop();
  }
}