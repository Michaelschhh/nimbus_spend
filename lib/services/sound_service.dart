import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static bool _enabled = true;
  static final Map<String, AudioPlayer> _players = {};

  /// Update the enabled state from settings
  static void setEnabled(bool value) {
    _enabled = value;
    debugPrint("SoundService: Enabled set to $value");
  }

  /// Initialize audio settings and pre-cache sound players
  static Future<void> init() async {
    // Players are created but sources are set in background to not block main thread
    _loadSound('pop.mp3');
    _loadSound('success.mp3');
    _loadSound('chaching.mp3');
    _loadSound('delete.mp3');
    _loadSound('welcome.mp3');
    debugPrint("SoundService: Initialization started");
  }

  static Future<void> _loadSound(String s) async {
    try {
      final player = AudioPlayer();
      await player.setSource(AssetSource('sounds/$s'));
      await player.setVolume(0.5);
      _players[s] = player;
    } catch (e) {
      debugPrint("SoundService: Failed to pre-cache $s: $e");
    }
  }

  static Future<void> play(String fileName) async {
    if (!_enabled) return;
    
    try {
      final player = _players[fileName];
      if (player != null) {
        // Stop, rewind to beginning, and resume for reliable rapid playback
        await player.stop();
        await player.play(AssetSource('sounds/$fileName'), volume: 0.5);
      } else {
        // Lazy load and play for any missed sounds
        final tempPlayer = AudioPlayer();
        await tempPlayer.play(AssetSource('sounds/$fileName'), volume: 0.5);
        tempPlayer.onPlayerStateChanged.listen((state) {
          if (state == PlayerState.completed) {
            tempPlayer.dispose();
          }
        });
      }
    } catch (e) {
      debugPrint("SoundService Play Error ($fileName): $e");
    }
  }

  static void welcome() => play('welcome.mp3');
  static void success() => play('success.mp3');
  static void chaching() => play('chaching.mp3');
  static void delete() => play('delete.mp3');
  static void tap() => play('pop.mp3');
}