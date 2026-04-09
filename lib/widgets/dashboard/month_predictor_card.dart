import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../theme/colors.dart';
import '../../providers/settings_provider.dart';
import '../../services/shader_service.dart';
import '../common/liquid_physics_button.dart';

class MonthPredictorCard extends StatefulWidget {
  final double predictedTotal;
  final double budget;
  final String currency;

  const MonthPredictorCard({
    super.key,
    required this.predictedTotal,
    required this.budget,
    required this.currency,
  });

  @override
  State<MonthPredictorCard> createState() => _MonthPredictorCardState();
}

class _MonthPredictorCardState extends State<MonthPredictorCard> {
  double _tiltX = 0;
  double _tiltY = 0;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>().settings;
    final bool isOver = widget.predictedTotal > widget.budget;
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
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ShaderService.getLiquidGlassFilter(
                tilt: Offset(_tiltY * 0.1, -_tiltX * 0.1),
              ) ?? ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (isOver ? AppColors.danger : AppColors.success).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 7.0,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.trendingUp,
                          color: isOver ? AppColors.danger : AppColors.success,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Month Prediction",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isOver
                          ? "You might exceed your budget by ${widget.predictedTotal - widget.budget}"
                          : "You're on track to save ${widget.budget - widget.predictedTotal}!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isOver ? AppColors.danger : AppColors.success,
                      ),
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
