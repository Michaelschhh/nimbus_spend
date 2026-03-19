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
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.cloudRain, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), size: 40),
          const SizedBox(height: 10),
          Text(
            "NIMBUS SPEND",
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          Divider(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26), height: 40),
          Text(
            monthName.toUpperCase(),
            style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87), fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(
            Formatters.currency(totalSpent, currency),
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          _buildStatRow(context, "Spending Score", "$spendingScore/100"),
          _buildStatRow(context, "Top Category", topCategory),
          _buildStatRow(context, "Life Cost", "${lifeHours.toStringAsFixed(1)} Hours"),
          const SizedBox(height: 30),
          Text(
            "Tracked with Nimbus Spend",
            style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87))),
          Text(
            value,
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
