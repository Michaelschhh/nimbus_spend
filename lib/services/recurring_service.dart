import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../providers/settings_provider.dart';
import '../providers/expense_provider.dart';

class RecurringService {
  static Future<void> checkAllCycles(SettingsProvider sProv, ExpenseProvider eProv) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // 1. RECURRING EXPENSES AUTO-LOG
    final List<Expense> recurringItems = eProv.expenses.where((e) => e.isRecurring).toList();
    for (var item in recurringItems) {
      String key = "last_run_${item.id}";
      String? last = prefs.getString(key);
      DateTime lastRun = last != null ? DateTime.parse(last) : item.date;

      if (_due(lastRun, item.recurringFrequency ?? "Monthly")) {
        final next = Expense(
          amount: item.amount,
          category: item.category,
          date: now,
          note: "Auto-logged: ${item.category}",
          isRecurring: true,
          recurringFrequency: item.recurringFrequency,
          lifeCostHours: item.lifeCostHours,
        );
        await eProv.addExpense(next, sProv);
        await prefs.setString(key, now.toIso8601String());
      }
    }

    // 2. BUDGET ALLOCATION LOGIC
    int lastAlloc = prefs.getInt('last_alloc_month') ?? 0;
    if (lastAlloc != 0 && lastAlloc != now.month) {
      // Logic for rollover budget to resources happened in settings_provider.dart
      await prefs.setInt('last_alloc_month', now.month);
    }
  }

  static bool _due(DateTime last, String freq) {
    final now = DateTime.now();
    if (freq == "Daily") return now.difference(last).inDays >= 1;
    if (freq == "Weekly") return now.difference(last).inDays >= 7;
    return now.month != last.month;
  }
}