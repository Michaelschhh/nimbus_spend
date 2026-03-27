import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';
import '../services/widget_service.dart'; // Added import
import '../services/notification_service.dart'; // Corrected import
import '../providers/settings_provider.dart';

class ExpenseProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Expense> _expenses = [];
  Set<String> _hiddenIds = {};

  List<Expense> get expenses => _expenses;
  List<Expense> get visibleExpenses => _expenses.where((e) => !_hiddenIds.contains(e.id)).toList();
  List<Expense> get hiddenExpenses => _expenses.where((e) => _hiddenIds.contains(e.id)).toList();
  bool isHidden(String id) => _hiddenIds.contains(id);

  double get totalSpentThisMonth {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month && e.fundingSource == 'allowance')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalSpentToday {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month && e.date.day == now.day && e.fundingSource == 'allowance')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> fetchExpenses() async {
    final data = await _storage.queryAll('expenses');
    _expenses = data.map((e) => Expense.fromMap(e)).toList();
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    // Load hidden IDs
    final prefs = await SharedPreferences.getInstance();
    _hiddenIds = (prefs.getStringList('hidden_transaction_ids') ?? []).toSet();
    notifyListeners();
  }

  Future<void> hideTransaction(String id) async {
    _hiddenIds.add(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('hidden_transaction_ids', _hiddenIds.toList());
    notifyListeners();
  }

  Future<void> unhideTransaction(String id) async {
    _hiddenIds.remove(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('hidden_transaction_ids', _hiddenIds.toList());
    notifyListeners();
  }

  Future<void> addExpense(Expense expense, SettingsProvider settings, {bool skipResourceUpdate = false}) async {
    // Check state before adding
    double budget = settings.settings.monthlyBudget;
    double alreadySpent = totalSpentThisMonth;
    
    try {
      await _storage.insert('expenses', expense.toMap());
      _expenses.insert(0, expense);
      
      // NOTIFICATION LOGIC: Fire only when crossing the threshold
      if (alreadySpent < budget && (alreadySpent + expense.amount) >= budget) {
        NotificationService.showNotification(
          id: 555,
          title: "Allowance Depleted ⚠️",
          body: "You are now spending from your core Available Resources.",
        );
      }

      // Only deduct from resources if the caller hasn't already handled it
      if (!skipResourceUpdate) {
        await settings.updateResources(-expense.amount);
      }
      notifyListeners();

      // Update Home Widget
      final isDark = settings.settings.isDarkMode;
      final theme = isDark ? ThemeData.dark() : ThemeData.light();
      
      WidgetService.updateWidgetData(
        monthlyAllowance: settings.settings.monthlyBudget - totalSpentThisMonth,
        spentToday: totalSpentToday,
        currency: settings.settings.currency,
        primaryColor: theme.primaryColor,
        backgroundColor: theme.scaffoldBackgroundColor,
        textColor: isDark ? Colors.white : Colors.black,
      );
    } catch (e) {
      debugPrint("Error adding expense: $e");
    }
  }

  Future<void> deleteExpense(String id, SettingsProvider settings) async {
    final idx = _expenses.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final expense = _expenses[idx];
      double refund = expense.amount;
      try {
        await _storage.delete('expenses', id);
        _expenses.removeAt(idx);
        
        // REVERT (Refund resources ONLY if it was deducted from resources)
        if (expense.fundingSource == 'resources') {
          await settings.addToResources(refund);
        }
        // Note: For 'allowance', removing from list automatically restores 'totalSpentThisMonth'
        notifyListeners();

        // Update Home Widget
        final isDark = settings.settings.isDarkMode;
        final theme = isDark ? ThemeData.dark() : ThemeData.light();
        
        WidgetService.updateWidgetData(
          monthlyAllowance: settings.settings.monthlyBudget - totalSpentThisMonth,
          spentToday: totalSpentToday,
          currency: settings.settings.currency,
          primaryColor: theme.primaryColor,
          backgroundColor: theme.scaffoldBackgroundColor,
          textColor: isDark ? Colors.white : Colors.black,
        );
      } catch (e) {
        debugPrint("Error deleting expense: $e");
      }
    }
  }

  Future<void> updateExpense(Expense expense, Expense oldExpense, SettingsProvider settings) async {
    await _storage.update('expenses', expense.toMap(), expense.id);
    
    // Reverse the old expense effect if it was funded by resources
    if (oldExpense.fundingSource == 'resources') {
      await settings.addToResources(oldExpense.amount);
    }
    
    // Apply the new expense effect if it is funded by resources
    if (expense.fundingSource == 'resources') {
      await settings.deductFromResources(expense.amount);
    }
    
    await fetchExpenses();
  }

  Future<void> deleteExpenseByLinkedId(String linkedId, SettingsProvider sProv) async {
    final toDelete = _expenses.where((e) => e.linkedId == linkedId).toList();
    for (var e in toDelete) {
      await deleteExpense(e.id, sProv);
    }
  }

  double getSpentForMonth(int year, int month) {
    return _expenses
        .where((e) => e.date.year == year && e.date.month == month && e.fundingSource == 'allowance')
        .fold(0, (sum, e) => sum + e.amount);
  }

  void clear() {
    _expenses = [];
    notifyListeners();
  }
}