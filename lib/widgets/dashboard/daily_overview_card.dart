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
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Spend",
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.currency(spentToday, currency),
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
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
