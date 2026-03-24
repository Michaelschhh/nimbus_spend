import 'dart:math';

class DateUtils {
  /// Returns a DateTime with the day clamped to the maximum days in the target month.
  /// This prevents the "February 31st" overflow bug where DateTime(2024, 2, 31) 
  /// would result in March 2nd.
  static DateTime clampedDateTime(int year, int month, int day) {
    // month can be > 12 or < 1, DateTime handles year rollover automatically
    // but we need to find the actual month and year first to get the correct daysInMonth
    DateTime firstOfTargetMonth = DateTime(year, month, 1);
    int targetYear = firstOfTargetMonth.year;
    int targetMonth = firstOfTargetMonth.month;
    
    int daysInMonth = _getDaysInMonth(targetYear, targetMonth);
    return DateTime(targetYear, targetMonth, min(day, daysInMonth));
  }

  static int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      bool isLeapYear = (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const daysInMonths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysInMonths[month - 1];
  }
}
