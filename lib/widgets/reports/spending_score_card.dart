import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../theme/colors.dart';

class SpendingScoreCard extends StatelessWidget {
  final int score;

  const SpendingScoreCard({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    Color scoreColor = score > 80
        ? AppColors.success
        : (score > 50 ? AppColors.warning : AppColors.danger);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircularPercentIndicator(
              radius: 60.0,
              lineWidth: 12.0,
              percent: score / 100,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$score",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Score",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              progressColor: scoreColor,
              backgroundColor: scoreColor.withOpacity(0.1),
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 1000,
            ),
            const SizedBox(height: 15),
            const Text(
              "Your weekly financial health score based on your budget discipline.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
