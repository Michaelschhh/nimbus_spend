import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  /// Initialize audio settings
  static Future<void> init() async {
    try {
      // Audio players don't strictly require init, but we provide it 
      // to satisfy the main.dart boot sequence.
      debugPrint("Institutional Sound Engine: Initialized");
    } catch (e) {
      debugPrint("Sound Init Error: $e");
    }
  }

  static Future<void> play(String fileName) async {
    try {
      // We use volume 0.5 to keep it subtle like a real system sound
      await _player.play(AssetSource('sounds/$fileName'), volume: 0.5);
    } catch (e) {
      debugPrint("Sound Play Error: $e");
    }
  }

  static void welcome() => play('welcome.mp3');
  static void success() => play('success.mp3');
  static void chaching() => play('chaching.mp3');
  static void delete() => play('delete.mp3');
  static void tap() => play('pop.mp3');
}