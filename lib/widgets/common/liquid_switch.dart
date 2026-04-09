import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:async';
import '../../providers/settings_provider.dart';
import '../../services/shader_service.dart';
import 'liquid_physics_button.dart';

class LiquidSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const LiquidSwitch({super.key, required this.value, required this.onChanged});

  @override
  State<LiquidSwitch> createState() => _LiquidSwitchState();
}

class _LiquidSwitchState extends State<LiquidSwitch> {
  bool _isAnimating = false;
  Timer? _animTimer;

  @override
  void didUpdateWidget(covariant LiquidSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      setState(() => _isAnimating = true);
      _animTimer?.cancel();
      _animTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _isAnimating = false);
      });
    }
  }

  @override
  void dispose() {
    _animTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>().settings;
    final isWater = s.liquidEffectEnabled;
    final resolvedColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final trackColor = widget.value 
        ? resolvedColor 
        : (isDark ? Colors.white24 : Colors.grey.withOpacity(0.3));

    final trackBorder = widget.value 
        ? Border.all(color: resolvedColor, width: 1.5)
        : Border.all(color: (isDark ? Colors.white10 : Colors.black12), width: 1.5);

    Widget track;
    if (isWater && _isAnimating) {
      // Full glass track during active movement
      final filter = ShaderService.getLiquidGlassFilter(intensity: s.refractionIntensity);
      track = ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: BackdropFilter(
          filter: filter ?? ImageFilter.blur(sigmaX: s.blurIntensity * 100, sigmaY: s.blurIntensity * 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            width: 60,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              color: Colors.white.withOpacity(isDark ? 0.15 : 0.3),
              border: Border.all(color: Colors.white.withOpacity(isDark ? 0.35 : 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(color: resolvedColor.withOpacity(0.2), blurRadius: 10, spreadRadius: 1),
              ],
            ),
          ),
        ),
      );
    } else {
      track = AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        width: 60,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          color: isWater ? (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)) : trackColor,
          border: isWater ? Border.all(color: Colors.white.withOpacity(0.1), width: 1.5) : trackBorder,
        ),
      );
    }

    Widget thumbWidget = Container(
      width: 27,
      height: 27,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isWater ? 0.3 : 0.1), blurRadius: 4, offset: const Offset(0, 2))
        ]
      ),
    );

    if (isWater) {
      final filter = ShaderService.getLiquidGlassFilter(intensity: s.refractionIntensity);
      thumbWidget = LiquidPhysicsButton(
        isWaterTheme: true,
        onTap: () => widget.onChanged(!widget.value),
        child: ClipOval(
          child: BackdropFilter(
            filter: filter ?? ImageFilter.blur(sigmaX: s.blurIntensity * 100, sigmaY: s.blurIntensity * 100),
            child: Container(
              width: 27, height: 27,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.value ? resolvedColor.withOpacity(0.8) : Colors.white.withOpacity(0.4),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 0 && !widget.value) {
          widget.onChanged(true);
        } else if (details.delta.dx < 0 && widget.value) {
          widget.onChanged(false);
        }
        if (!_isAnimating) {
          setState(() => _isAnimating = true);
          _animTimer?.cancel();
          _animTimer = Timer(const Duration(milliseconds: 600), () {
            if (mounted) setState(() => _isAnimating = false);
          });
        }
      },
      child: SizedBox(
        width: 60,
        height: 34,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            track,
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              left: widget.value ? 29 : 4,
              child: thumbWidget,
            ),
          ],
        ),
      ),
    );
  }
}
