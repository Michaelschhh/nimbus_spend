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
    int lastAllocMonth = prefs.getInt('last_alloc_month') ?? now.month;
    int lastAllocYear = prefs.getInt('last_alloc_year') ?? now.year;
    
    int missedMonths = _calculateMissedMonths(lastAllocYear, lastAllocMonth, now.year, now.month);
    
    if (missedMonths > 0) {
      // Inject missed funds
      await sProv.addRolloverFunds(missedMonths * sProv.settings.monthlyBudget);
      await prefs.setInt('last_alloc_month', now.month);
      await prefs.setInt('last_alloc_year', now.year);
    } else if (prefs.getInt('last_alloc_month') == null) {
        // Initial setup edgecase
        await prefs.setInt('last_alloc_month', now.month);
        await prefs.setInt('last_alloc_year', now.year);
    }
  }

  static int _calculateMissedMonths(int startYear, int startMonth, int endYear, int endMonth) {
    if (startYear == 0 || startMonth == 0) return 0;
    int yearDiff = endYear - startYear;
    int monthDiff = endMonth - startMonth;
    return (yearDiff * 12) + monthDiff;
  }

  static bool _due(DateTime last, String freq) {
    final now = DateTime.now();
    if (freq == "Daily") return now.difference(last).inDays >= 1;
    if (freq == "Weekly") return now.difference(last).inDays >= 7;
    return now.month != last.month;
  }
}