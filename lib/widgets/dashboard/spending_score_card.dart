import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../theme/colors.dart';

class SpendingScoreCard extends StatelessWidget {
  final int score;

  const SpendingScoreCard({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
              percent: score / 100,
              center: Text(
                "$score",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              progressColor: score > 70 ? AppColors.success : AppColors.warning,
              backgroundColor: Colors.grey.shade200,
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 1500,
            ),
          ],
        ),
      ),
    );
  }
}
