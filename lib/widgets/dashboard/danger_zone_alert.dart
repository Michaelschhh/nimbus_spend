import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/colors.dart';

class DangerZoneAlert extends StatelessWidget {
  final double percentage;
  const DangerZoneAlert({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.zap,
            color: AppColors.danger,
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "DANGER ZONE",
                  style: TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  "You've used ${percentage.toStringAsFixed(0)}% of your monthly budget.",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().shake(duration: 500.ms);
  }
}
