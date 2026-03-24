import 'package:flutter/material.dart';
import '../../models/ai_insight.dart';
import '../../theme/colors.dart';
import '../../utils/responsive.dart';

class InsightCard extends StatelessWidget {
  final AIInsight insight;
  
  const InsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: Responsive.sp(8, context)),
      padding: EdgeInsets.all(Responsive.sp(16, context)),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(insight.icon, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  insight.title,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.fs(14, context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            insight.body,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: Responsive.fs(12, context),
              height: 1.4,
            ),
          ),
          if (insight.actionLabel != null && insight.route != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, insight.route!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  insight.actionLabel!,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.fs(11, context),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
