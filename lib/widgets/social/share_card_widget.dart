import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../utils/formatters.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ShareCardWidget extends StatelessWidget {
  final String monthName;
  final double totalSpent;
  final String topCategory;
  final double lifeHours;
  final int spendingScore;
  final String currency;

  const ShareCardWidget({
    super.key,
    required this.monthName,
    required this.totalSpent,
    required this.topCategory,
    required this.lifeHours,
    required this.spendingScore,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.cloudRain, color: Colors.white, size: 40),
          const SizedBox(height: 10),
          const Text(
            "NIMBUS SPEND",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const Divider(color: Colors.white24, height: 40),
          Text(
            monthName.toUpperCase(),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(
            Formatters.currency(totalSpent, currency),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          _buildStatRow("Spending Score", "$spendingScore/100"),
          _buildStatRow("Top Category", topCategory),
          _buildStatRow("Life Cost", "${lifeHours.toStringAsFixed(1)} Hours"),
          const SizedBox(height: 30),
          const Text(
            "Tracked with Nimbus Spend",
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
