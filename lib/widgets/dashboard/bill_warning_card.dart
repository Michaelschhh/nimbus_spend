import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/bill.dart';
import '../../theme/colors.dart';

class BillWarningCard extends StatelessWidget {
  final List<Bill> upcomingBills;
  const BillWarningCard({super.key, required this.upcomingBills});

  @override
  Widget build(BuildContext context) {
    if (upcomingBills.isEmpty) return const SizedBox.shrink();

    return Card(
      color: AppColors.warning.withOpacity(0.1),
      child: ListTile(
        leading: const Icon(LucideIcons.alertCircle, color: AppColors.warning),
        title: Text(
          "${upcomingBills.length} Bill(s) due soon!",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.warning,
          ),
        ),
        subtitle: Text("Next: ${upcomingBills.first.name}"),
      ),
    );
  }
}
