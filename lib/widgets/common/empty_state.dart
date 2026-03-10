import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/colors.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState({
    super.key,
    this.message = "Nothing here yet...",
    this.icon = LucideIcons.ghost,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.textSecondary.withOpacity(0.2))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(
                begin: -10,
                end: 10,
                duration: 2.seconds,
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
