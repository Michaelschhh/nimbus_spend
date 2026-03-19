import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../providers/settings_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/bills_provider.dart';
import '../providers/debt_provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/savings_provider.dart';
import 'notification_service.dart';
import '../utils/life_cost_utils.dart';

class RecurringService {
  static Future<void> checkAllCycles(SettingsProvider sProv, ExpenseProvider eProv, BillsProvider bProv, DebtProvider dProv, SubscriptionProvider subProv, SavingsProvider prov) async {
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
          fundingSource: item.fundingSource,
        );
        
        if (item.fundingSource == 'allowance') {
          await eProv.addExpense(next, sProv, skipResourceUpdate: true);
        } else if (item.fundingSource == 'resources') {
          await eProv.addExpense(next, sProv, skipResourceUpdate: true);
          await sProv.deductFromResources(item.amount);
        } else {
          await eProv.addExpense(next, sProv, skipResourceUpdate: true);
        }
        await prefs.setString(key, now.toIso8601String());
      }
    }

    // 2. BUDGET ALLOCATION LOGIC (Monthly Rollover)
    int lastAllocMonth = prefs.getInt('last_alloc_month') ?? now.month;
    int lastAllocYear = prefs.getInt('last_alloc_year') ?? now.year;
    
    // Check if a new month has started
    if (now.year > lastAllocYear || (now.year == lastAllocYear && now.month > lastAllocMonth)) {
      // 1. Calculate remainder of the PREVIOUS month
      // We process each missed month sequentially to ensure accurate accounting
      int currentY = lastAllocYear;
      int currentM = lastAllocMonth;
      
      while (currentY < now.year || (currentY == now.year && currentM < now.month)) {
        double spent = eProv.getSpentForMonth(currentY, currentM);
        double remainder = sProv.settings.monthlyBudget - spent;
        
        // Return unused allowance to resources (if positive)
        // If negative, it means they overspent their allowance (which is allowed but reduces resources)
        await sProv.addToResources(remainder);
        
        // --- SALARY AUTOMATION ---
        if (sProv.settings.isSalaryEarner) {
          await sProv.addToResources(sProv.settings.salaryAmount);
          await NotificationService.showAutoPayNotification("Salary Deposited", sProv.settings.salaryAmount);
        }
        
        // Deduct next month's allowance from resources
        await sProv.deductFromResources(sProv.settings.monthlyBudget);
        
        // Advance month
        currentM++;
        if (currentM > 12) {
          currentM = 1;
          currentY++;
        }
      }
      
      await prefs.setInt('last_alloc_month', now.month);
      await prefs.setInt('last_alloc_year', now.year);
    }

    // 3. SUBSCRIPTIONS AUTO-LOG
    for (var sub in subProv.subscriptions.where((s) => s.isActive)) {
      if (now.isAfter(sub.nextDueDate) || now.isAtSameMomentAs(sub.nextDueDate)) {
        // Log expense if not 'none'
        if (sub.defaultRouting != 'none') {
          final exp = Expense(
            amount: sub.amount,
            date: now,
            category: sub.category,
            note: 'Subscription: ${sub.name}',
            isRecurring: false,
            lifeCostHours: LifeCostUtils.calculate(sub.amount, sProv.settings.hourlyWage),
            fundingSource: sub.defaultRouting,
          );
          
          if (sub.defaultRouting == 'allowance') {
            await eProv.addExpense(exp, sProv, skipResourceUpdate: true);
          } else if (sub.defaultRouting == 'resources') {
            await eProv.addExpense(exp, sProv, skipResourceUpdate: true);
            sProv.deductFromResources(sub.amount);
          }
        }

        // Update Subscription Next Due Date
        DateTime next;
        if (sub.frequency == 'Weekly') {
          next = sub.nextDueDate.add(const Duration(days: 7));
        } else if (sub.frequency == 'Yearly') {
          next = DateTime(sub.nextDueDate.year + 1, sub.nextDueDate.month, sub.nextDueDate.day);
        } else {
          next = DateTime(sub.nextDueDate.year, sub.nextDueDate.month + 1, sub.nextDueDate.day);
        }
        await subProv.updateSubscription(sub.copyWith(nextDueDate: next));
        await NotificationService.showAutoPayNotification(sub.name, sub.amount);
      }
    }

    // 4. SAVINGS MATURITY CHECK
    for (var s in prov.savings.where((s) => !s.isMatured)) {
      if (now.isAfter(s.endDate)) {
        await prov.markAsMatured(s.id);
        await NotificationService.showAutoPayNotification("Goal Matured: ${s.description}", s.amount);
      }
    }

    // 5. BILLS AND DEBTS CHECKS
    _checkBillsAndDebts(sProv, eProv, bProv, dProv);
  }

  static Future<void> _checkBillsAndDebts(SettingsProvider sProv, ExpenseProvider eProv, BillsProvider bProv, DebtProvider dProv) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var b in bProv.bills.where((b) => !b.isPaid)) {
      final dueDay = DateTime(b.dueDate.year, b.dueDate.month, b.dueDate.day);
      
      if (b.autoPay && (dueDay.isBefore(today) || dueDay.isAtSameMomentAs(today))) {
        await bProv.markAsPaid(b.id);
        
        if (b.defaultRouting != 'none') {
          final expense = Expense(
            amount: b.amount,
            category: b.category,
            date: now,
            note: 'Auto-Paid Bill: ${b.name}',
            lifeCostHours: LifeCostUtils.calculate(b.amount, sProv.settings.hourlyWage),
            fundingSource: b.defaultRouting,
          );
          
          // Log expense based on routing
          if (b.defaultRouting == 'allowance') {
            await eProv.addExpense(expense, sProv, skipResourceUpdate: true);
          } else if (b.defaultRouting == 'resources') {
            await eProv.addExpense(expense, sProv, skipResourceUpdate: true);
            await sProv.deductFromResources(b.amount);
          }
        }
        await NotificationService.showAutoPayNotification(b.name, b.amount);
      } else if (dueDay.isBefore(today)) {
        await NotificationService.showOverdueNotification(b.name, b.amount);
      }
    }

    for (var d in dProv.debts.where((d) => !d.isSettled)) {
      if (d.dueDate != null) {
        final dueDay = DateTime(d.dueDate!.year, d.dueDate!.month, d.dueDate!.day);
        if (dueDay.isBefore(today)) {
          await NotificationService.showOverdueNotification("Debt: ${d.personName}", d.remainingAmount);
        }
      }
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