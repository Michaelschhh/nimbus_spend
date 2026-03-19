import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ColorUtils {
  static Color categoryColor(String c, BuildContext context) {
    if (c.contains("Food")) return AppColors.success;
    if (c.contains("Shopping") || c.contains("Debts")) return Theme.of(context).primaryColor;
    if (c.contains("Bills")) return AppColors.warning;
    if (c.contains("Transport")) return AppColors.info;
    if (c.contains("Health")) return AppColors.danger;
    
    // Generate distinct color from string hash
    final index = c.hashCode.abs() % Colors.primaries.length;
    return Colors.primaries[index];
  }
}
