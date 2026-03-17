class LifeCostUtils {
  static double calculate(double amount, double hourlyWage) {
    if (hourlyWage <= 0) return 0.0;
    return amount / hourlyWage;
  }

  static String format(double hours) {
    if (hours < 1) {
      final mins = (hours * 60).toStringAsFixed(0);
      return "$mins mins";
    }
    return "${hours.toStringAsFixed(1)} hrs";
  }
}
