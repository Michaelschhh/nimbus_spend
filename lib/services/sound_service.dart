import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
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
      final player = AudioPlayer();
      // We use volume 0.5 to keep it subtle like a real system sound
      await player.play(AssetSource('sounds/$fileName'), volume: 0.5);
      
      // Dispose of the player after it completes to free resources
      player.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed) {
          player.dispose();
        }
      });
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