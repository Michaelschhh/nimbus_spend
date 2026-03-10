import 'package:intl/intl.dart';

class Formatters {
  static String currency(double amount, String code) {
    final format = NumberFormat.simpleCurrency(name: code);
    return format.format(amount);
  }

  static String date(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
