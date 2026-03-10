import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/colors.dart';

class PatternCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const PatternCard({
    super.key,
    required this.title,
    required this.description,
    this.icon = LucideIcons.trendingUp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
