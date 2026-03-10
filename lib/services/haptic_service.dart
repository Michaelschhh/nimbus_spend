import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HapticService {
  static bool _enabled = true;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool('haptics_enabled') ?? true;
  }

  static Future<void> light() async {
    if (!_enabled) return;
    await HapticFeedback.lightImpact();
  }

  static Future<void> heavy() async {
    if (!_enabled) return;
    await HapticFeedback.heavyImpact();
  }

  static Future<void> success() async {
    if (!_enabled) return;
    await HapticFeedback.vibrate();
  }
}