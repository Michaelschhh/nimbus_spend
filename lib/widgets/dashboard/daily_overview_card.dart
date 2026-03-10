import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/life_cost_badge.dart';

class DailyOverviewCard extends StatelessWidget {
  final double spentToday;
  final double lifeHours;
  final String currency;

  const DailyOverviewCard({
    super.key,
    required this.spentToday,
    required this.lifeHours,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Spend",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.currency(spentToday, currency),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LifeCostBadge(hours: lifeHours, isLarge: true),
        ],
      ),
    );
  }
}
