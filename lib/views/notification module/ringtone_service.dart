import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class RingtoneService {

  /// 🔊 START CONTINUOUS RING
  static void start() {
    FlutterRingtonePlayer().play(
      android: AndroidSounds.ringtone,
      ios: IosSounds.glass,
      looping: true,     // 🔥 keeps ringing
      volume: 1.0,
      asAlarm: true,     // 🔥 works even in silent mode
    );
  }

  /// 🛑 STOP RING
  static void stop() {
    FlutterRingtonePlayer().stop();
  }
}