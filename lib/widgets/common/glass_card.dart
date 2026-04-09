import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? color;

  GlassCard({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.1,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = color ?? (isDark ? Colors.white : Colors.black);
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: isDark 
                ? baseColor.withOpacity(opacity)
                : Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? baseColor.withOpacity(0.4) : Colors.black.withOpacity(0.15),
              width: 1.5, // Crisp thin glass inset style
            ),
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.5,
              colors: [
                Colors.white.withOpacity(isDark ? 0.1 : 0.3),
                Colors.transparent,
              ],
            ),
          ),
          child: Stack(
            children: [
               Positioned.fill(
                 child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(23),
                      gradient: const RadialGradient(
                         center: Alignment(-0.6, -0.4),
                         radius: 1.5,
                         colors: [Colors.white12, Colors.transparent],
                      ),
                      backgroundBlendMode: BlendMode.overlay,
                    ),
                 ),
               ),
               Positioned.fill(
                 child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(23),
                      gradient: const RadialGradient(
                         center: Alignment(0.6, 0.4),
                         radius: 1.5,
                         colors: [Colors.white12, Colors.transparent],
                      ),
                      backgroundBlendMode: BlendMode.overlay,
                    ),
                 ),
               ),
               child,
            ],
          ),
        ),
      ),
    );
  }
}
