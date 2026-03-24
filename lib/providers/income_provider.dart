import 'package:flutter/material.dart';
import '../models/income.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';
import '../utils/life_cost_utils.dart';
import 'settings_provider.dart';
import 'expense_provider.dart';

class IncomeProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Income> _incomes = [];

  List<Income> get incomes => _incomes;

  Future<void> fetchIncomes() async {
    final data = await _storage.queryAll('income');
    _incomes = data.map((i) => Income.fromMap(i)).toList();
    notifyListeners();
  }

  Future<void> addIncome(Income income, SettingsProvider sProv, ExpenseProvider eProv) async {
    await _storage.insert('income', income.toMap());
    _incomes.add(income);
    
    // Update available resources
    await sProv.addToResources(income.amount);
    
    // Log as a special "negative" expense for ledger accuracy
    final expense = Expense(
      amount: -income.amount,
      category: 'Income 💰',
      date: income.date,
      note: 'Income: ${income.source}',
      lifeCostHours: 0,
      fundingSource: 'none',
      linkedId: income.id,
    );
    await eProv.addExpense(expense, sProv, skipResourceUpdate: true);
    
    notifyListeners();
  }

  Future<void> updateIncome(Income updated, SettingsProvider sProv, ExpenseProvider eProv) async {
    final idx = _incomes.indexWhere((i) => i.id == updated.id);
    if (idx != -1) {
      final oldAmount = _incomes[idx].amount;
      await _storage.update('income', updated.toMap(), updated.id);
      _incomes[idx] = updated;

      // Unwind old amount and apply new amount
      await sProv.deductFromResources(oldAmount);
      await sProv.addToResources(updated.amount);

      // Re-link ledger
      await eProv.deleteExpenseByLinkedId(updated.id, sProv);
      final expense = Expense(
        amount: -updated.amount,
        category: 'Income 💰',
        date: updated.date,
        note: 'Income: ${updated.source}',
        lifeCostHours: 0,
        fundingSource: 'none',
        linkedId: updated.id,
      );
      await eProv.addExpense(expense, sProv, skipResourceUpdate: true);
      notifyListeners();
    }
  }

  Future<void> deleteIncome(String id, SettingsProvider sProv, ExpenseProvider eProv) async {
    final income = _incomes.firstWhere((i) => i.id == id);
    await _storage.delete('income', id);
    _incomes.removeWhere((i) => i.id == id);
    
    await sProv.deductFromResources(income.amount);
    await eProv.deleteExpenseByLinkedId(id, sProv);
    
    notifyListeners();
  }

  Future<void> clear() async {
    await _storage.clearTable('income');
    _incomes.clear();
    notifyListeners();
  }
}
