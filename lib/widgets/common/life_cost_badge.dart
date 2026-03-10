import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../utils/life_cost_utils.dart';
import '../../theme/colors.dart';

class LifeCostBadge extends StatelessWidget {
  final double hours;
  final bool isLarge;

  const LifeCostBadge({super.key, required this.hours, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isLarge ? 12 : 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lifeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lifeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.clock,
            size: isLarge ? 16 : 12,
            color: AppColors.lifeColor,
          ),
          const SizedBox(width: 4),
          Text(
            LifeCostUtils.format(hours),
            style: TextStyle(
              color: AppColors.lifeColor,
              fontWeight: FontWeight.bold,
              fontSize: isLarge ? 14 : 11,
            ),
          ),
        ],
      ),
    );
  }
}
