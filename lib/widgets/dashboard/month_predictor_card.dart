import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/colors.dart';

class MonthPredictorCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final bool isOver = predictedTotal > budget;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                  ? "You might exceed your budget by ${predictedTotal - budget}"
                  : "You're on track to save ${budget - predictedTotal}!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isOver ? AppColors.danger : AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
