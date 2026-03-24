import 'package:flutter/material.dart';
import '../models/bill.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class BillsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Bill> _bills = [];
  List<Bill> get bills => _bills;

  double get totalUnpaid => _bills
      .where((b) => !b.isPaid)
      .fold(0.0, (sum, b) => sum + b.amount);

  Future<void> fetchBills() async {
    final data = await _storage.queryAll('bills');
    _bills = data.map((b) => Bill.fromMap(b)).toList();
    _bills.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    notifyListeners();
  }

  Future<void> addBill(Bill bill) async {
    await _storage.insert('bills', bill.toMap());
    _bills.add(bill);
    _scheduleBillNotifications(bill);
    await fetchBills();
  }

  Future<void> deleteBill(String id) async {
    await _storage.delete('bills', id);
    NotificationService.cancelScheduled(id.hashCode);
    NotificationService.cancelScheduled(id.hashCode + 1);
    await fetchBills();
  }

  Future<void> updateBill(Bill bill) async {
    final index = _bills.indexWhere((b) => b.id == bill.id);
    if (index != -1) {
      await _storage.update('bills', bill.toMap(), bill.id);
      NotificationService.cancelScheduled(bill.id.hashCode);
      NotificationService.cancelScheduled(bill.id.hashCode + 1); // For the 3-day warning
      if (!bill.isPaid) {
        _scheduleBillNotifications(bill);
      }
      await fetchBills();
    }
  }

  void _scheduleBillNotifications(Bill bill) {
    if (bill.isPaid) return;
    
    // Day of
    NotificationService.scheduleItemNotification(
      id: bill.id.hashCode,
      title: 'Bill Due Today!',
      body: '${bill.name} for \$${bill.amount.toStringAsFixed(2)} is due today.',
      date: bill.dueDate,
    );
    // 3 days before
    final reminderDate = bill.dueDate.subtract(const Duration(days: 3));
    NotificationService.scheduleItemNotification(
      id: bill.id.hashCode + 1,
      title: 'Bill Due Soon',
      body: '${bill.name} for \$${bill.amount.toStringAsFixed(2)} is due in 3 days.',
      date: reminderDate,
    );
  }

  Future<void> markAsPaid(String id) async {
    final index = _bills.indexWhere((b) => b.id == id);
    if (index != -1) {
      final bill = _bills[index];

      final updated = Bill(
        id: bill.id,
        name: bill.name,
        amount: bill.amount,
        dueDate: bill.dueDate, // keep same due date
        frequency: bill.frequency,
        category: bill.category,
        isPaid: true,        // mark as paid
        paidDate: DateTime.now(),
        autoPay: bill.autoPay,
      );
      await updateBill(updated);
    }
  }

  void clear() {
    _bills = [];
    notifyListeners();
  }
}
