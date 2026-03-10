import 'package:flutter/material.dart';
import '../models/debt.dart';
import '../services/storage_service.dart';

class DebtProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Debt> _debts = [];
  List<Debt> get debts => _debts;

  Future<void> fetchDebts() async {
    final data = await _storage.queryAll('debts');
    _debts = data.map((d) => Debt.fromMap(d)).toList();
    notifyListeners();
  }

  Future<void> addDebt(Debt debt) async {
    await _storage.insert('debts', debt.toMap());
    fetchDebts();
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
      fetchDebts();
    }
  }
}
