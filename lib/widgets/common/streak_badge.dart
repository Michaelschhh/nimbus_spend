import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/colors.dart';

class StreakBadge extends StatelessWidget {
  final int streak;
  const StreakBadge({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("🔥", style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                "$streak Day Streak",
                style: const TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        )
        .animate(target: streak > 0 ? 1 : 0)
        .fadeIn()
        .scale()
        .shake(hz: 2, curve: Curves.easeInOut);
  }
}
