import 'package:flutter/material.dart';
import '../models/bill.dart';
import '../services/storage_service.dart';

class BillsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Bill> _bills = [];
  List<Bill> get bills => _bills;

  Future<void> fetchBills() async {
    final data = await _storage.queryAll('bills');
    _bills = data.map((b) => Bill.fromMap(b)).toList();
    _bills.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    notifyListeners();
  }

  Future<void> addBill(Bill bill) async {
    await _storage.insert('bills', bill.toMap());
    _bills.add(bill);
    fetchBills();
  }

  Future<void> markAsPaid(String id) async {
    final index = _bills.indexWhere((b) => b.id == id);
    if (index != -1) {
      final bill = _bills[index];
      final updated = Bill(
        id: bill.id,
        name: bill.name,
        amount: bill.amount,
        dueDate: bill.dueDate,
        frequency: bill.frequency,
        category: bill.category,
        isPaid: true,
        paidDate: DateTime.now(),
      );
      await _storage.update('bills', updated.toMap(), id);
      fetchBills();
    }
  }
}
