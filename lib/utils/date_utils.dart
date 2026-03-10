import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatShort(DateTime date) => DateFormat('MMM d').format(date);
  static String formatFull(DateTime date) =>
      DateFormat('MMMM d, yyyy').format(date);

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
