import 'package:flutter/material.dart';
import '../models/debt.dart';
import '../services/storage_service.dart';

class DebtProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Debt> _debts = [];
  List<Debt> get debts => _debts;

  double get totalIOwe => _debts
      .where((d) => !d.isOwedToMe && !d.isSettled)
      .fold(0.0, (sum, d) => sum + d.remainingAmount);

  double get totalOwedToMe => _debts
      .where((d) => d.isOwedToMe && !d.isSettled)
      .fold(0.0, (sum, d) => sum + d.remainingAmount);

  Future<void> fetchDebts() async {
    final data = await _storage.queryAll('debts');
    _debts = data.map((d) => Debt.fromMap(d)).toList();
    _debts.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return a.date.compareTo(b.date);
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    notifyListeners();
  }

  Future<void> addDebt(Debt debt) async {
    await _storage.insert('debts', debt.toMap());
    await fetchDebts();
  }

  Future<void> deleteDebt(String id) async {
    await _storage.delete('debts', id);
    await fetchDebts();
  }

  Future<void> updateDebt(Debt debt) async {
    final index = _debts.indexWhere((d) => d.id == debt.id);
    if (index != -1) {
      await _storage.update('debts', debt.toMap(), debt.id);
      await fetchDebts();
    }
  }

  Future<void> makePayment(String id, double amount) async {
    final index = _debts.indexWhere((d) => d.id == id);
    if (index != -1) {
      final debt = _debts[index];
      final newRemaining = (debt.remainingAmount - amount).clamp(0.0, debt.amount);
      final updated = Debt(
        id: debt.id,
        personName: debt.personName,
        amount: debt.amount,
        description: debt.description,
        date: debt.date,
        dueDate: debt.dueDate,
        isOwedToMe: debt.isOwedToMe,
        isSettled: newRemaining <= 0,
        remainingAmount: newRemaining,
      );
      await _storage.update('debts', updated.toMap(), id);
      await fetchDebts();
    }
  }

  Future<void> settleDebt(String id) async {
    final index = _debts.indexWhere((d) => d.id == id);
    if (index != -1) {
      final debt = _debts[index];
      final updated = Debt(
        id: debt.id,
        personName: debt.personName,
        amount: debt.amount,
        description: debt.description,
        date: debt.date,
        isOwedToMe: debt.isOwedToMe,
        isSettled: true,
        remainingAmount: 0,
      );
      await _storage.update('debts', updated.toMap(), id);
      await fetchDebts();
    }
  }

  void clear() {
    _debts = [];
    notifyListeners();
  }
}
