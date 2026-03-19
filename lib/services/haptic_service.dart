import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'dart:io';

class HapticService {
  static bool _enabled = true;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool('haptics_enabled') ?? true;
  }

  static Future<void> light() async {
    if (!_enabled) return;
    if (Platform.isAndroid) {
      bool hasCustom = await Vibration.hasCustomVibrationsSupport() ?? false;
      if (hasCustom) {
        Vibration.vibrate(duration: 40, amplitude: 255);
      } else {
        Vibration.vibrate(duration: 40);
      }
    } else {
      await HapticFeedback.mediumImpact();
    }
  }

  static Future<void> heavy() async {
    if (!_enabled) return;
    if (Platform.isAndroid) {
      bool hasCustom = await Vibration.hasCustomVibrationsSupport() ?? false;
      if (hasCustom) {
        Vibration.vibrate(duration: 80, amplitude: 255);
      } else {
        Vibration.vibrate(duration: 80);
      }
    } else {
      await HapticFeedback.heavyImpact();
    }
  }

  static Future<void> success() async {
    if (!_enabled) return;
    if (Platform.isAndroid) {
      Vibration.vibrate(pattern: [0, 50, 50, 50]);
    } else {
      await HapticFeedback.vibrate();
    }
  }
}