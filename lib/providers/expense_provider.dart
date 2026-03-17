import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../providers/settings_provider.dart';

class ExpenseProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  double get totalSpentThisMonth {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> fetchExpenses() async {
    final data = await _storage.queryAll('expenses');
    _expenses = data.map((e) => Expense.fromMap(e)).toList();
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addExpense(Expense expense, SettingsProvider settings) async {
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
      } else if ((alreadySpent + expense.amount) > budget) {
         // Optional: Repeat warning for every spend when over budget
      }

      // DUAL DRAIN - Only executed if DB insert succeeds
      await settings.updateResources(-expense.amount);
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding expense: $e");
    }
  }

  Future<void> deleteExpense(String id, SettingsProvider settings) async {
    final idx = _expenses.indexWhere((e) => e.id == id);
    if (idx != -1) {
      double refund = _expenses[idx].amount;
      try {
        await _storage.delete('expenses', id);
        _expenses.removeAt(idx);
        
        // REVERT (Refund resources)
        await settings.updateResources(refund);
        notifyListeners();
      } catch (e) {
        debugPrint("Error deleting expense: $e");
      }
    }
  }

  Future<void> updateExpense(Expense expense, double oldAmount, SettingsProvider settings) async {
    await _storage.update('expenses', expense.toMap(), expense.id);
    double diff = oldAmount - expense.amount;
    await settings.updateResources(diff);
    await fetchExpenses();
  }

  void clear() {
    _expenses = [];
    notifyListeners();
  }
}