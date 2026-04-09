import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../providers/settings_provider.dart';
import '../../services/shader_service.dart';

class LiquidSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final double intensity; // Extracted dynamically previously but keeping signature secure

  const LiquidSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.intensity = 0.05,
  });

  @override
  State<LiquidSlider> createState() => _LiquidSliderState();
}

class _LiquidSliderState extends State<LiquidSlider> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>().settings;
    final isWater = s.themeIndex == 10 || s.liquidEffectEnabled;

    if (!isWater) {
      return Slider(
        value: widget.value,
        onChanged: widget.onChanged,
        min: widget.min,
        max: widget.max,
        activeColor: Theme.of(context).primaryColor,
      );
    }

    // Liquid Glass custom slider rendering
    final double intensity = _isDragging ? s.refractionIntensity * 4.0 : s.refractionIntensity;
    final double blurAmt = _isDragging ? s.blurIntensity * 150 : s.blurIntensity * 100;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Normalize value
        final percentage = (widget.value - widget.min) / (widget.max - widget.min);
        // Calculate thumb position limiting strictly into bounds
        final thumbSize = _isDragging ? 32.0 : 24.0;
        final position = percentage * (width - thumbSize);
        
        return GestureDetector(
          onHorizontalDragDown: (details) => setState(() => _isDragging = true),
          onHorizontalDragUpdate: (details) {
            double localDx = details.localPosition.dx;
            final pct = (localDx / width).clamp(0.0, 1.0);
            widget.onChanged(widget.min + (pct * (widget.max - widget.min)));
          },
          onHorizontalDragEnd: (details) => setState(() => _isDragging = false),
          child: Container(
            height: 48, // Gesture hit target
            color: Colors.transparent,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Solid Native Track
                Container(
                  height: _isDragging ? 10.0 : 6.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                // Active Solid Track
                Container(
                  width: position + (thumbSize / 2),
                  height: _isDragging ? 10.0 : 6.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withOpacity(_isDragging ? 0.7 : 0.5),
                  ),
                ),
                // Pure Water Bubble Glass Thumb
                Positioned(
                  left: position,
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ShaderService.getLiquidGlassFilter(
                          intensity: intensity,
                          blurAmt: blurAmt,
                          size: Size(thumbSize, thumbSize),
                          shape: 1, // SHAPE: pill/slider/sphere
                        ) ?? ImageFilter.blur(sigmaX: blurAmt, sigmaY: blurAmt),
                      child: Container(
                        width: thumbSize,
                        height: thumbSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.3),
                          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
