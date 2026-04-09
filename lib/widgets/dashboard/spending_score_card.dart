import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../theme/colors.dart';
import '../../providers/settings_provider.dart';
import '../../services/shader_service.dart';

class SpendingScoreCard extends StatefulWidget {
  final int score;

  const SpendingScoreCard({super.key, required this.score});

  @override
  State<SpendingScoreCard> createState() => _SpendingScoreCardState();
}

class _SpendingScoreCardState extends State<SpendingScoreCard> {
  double _tiltX = 0;
  double _tiltY = 0;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>().settings;
    return GestureDetector(
      onPanUpdate: (d) => setState(() {
        _tiltY += d.delta.dx * 0.01;
        _tiltX -= d.delta.dy * 0.01;
        _tiltX = _tiltX.clamp(-0.15, 0.15);
        _tiltY = _tiltY.clamp(-0.15, 0.15);
      }),
      onPanEnd: (_) => setState(() { _tiltX = 0; _tiltY = 0; }),
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_tiltX)
          ..rotateY(_tiltY),
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ShaderService.getLiquidGlassFilter(
                intensity: s.refractionIntensity,
                tilt: Offset(_tiltY * 0.1, -_tiltX * 0.1),
              ) ?? ImageFilter.blur(sigmaX: s.blurIntensity * 100, sigmaY: s.blurIntensity * 100),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 7.0,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Spending Score",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    CircularPercentIndicator(
                      radius: 50.0,
                      lineWidth: 10.0,
                      percent: widget.score / 100,
                      center: Text(
                        "${widget.score}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      progressColor: widget.score > 70 ? AppColors.success : AppColors.warning,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      circularStrokeCap: CircularStrokeCap.round,
                      animation: true,
                      animationDuration: 1500,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
