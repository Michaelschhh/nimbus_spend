import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ShaderService {
  static ui.FragmentProgram? _liquidProgram;

  static Future<void> init() async {
    try {
      _liquidProgram = await ui.FragmentProgram.fromAsset('assets/shaders/liquid.frag');
    } catch (e) {
      debugPrint("Failed to load liquid shader: $e");
    }
  }

  static ui.ImageFilter? getLiquidGlassFilter({
    double intensity = 0.05, 
    double blurAmt = 0.0,
    Offset tilt = Offset.zero,
    Size? size,
    int shape = 0,
  }) {
    if (_liquidProgram == null) {
      if (blurAmt > 0) return ui.ImageFilter.blur(sigmaX: blurAmt, sigmaY: blurAmt);
      return null;
    }
    
    final shader = _liquidProgram!.fragmentShader();
    shader.setFloat(0, size?.width ?? 400.0);
    shader.setFloat(1, size?.height ?? 800.0);
    shader.setFloat(2, intensity);
    shader.setFloat(3, tilt.dx);
    shader.setFloat(4, tilt.dy);
    shader.setFloat(5, shape.toDouble());
    
    final shaderFilter = ui.ImageFilter.shader(shader);
    
    if (blurAmt > 0) {
      return ui.ImageFilter.compose(
        outer: shaderFilter, 
        inner: ui.ImageFilter.blur(sigmaX: blurAmt, sigmaY: blurAmt)
      );
    }
    
    return shaderFilter;
  }
}
