import 'package:flutter/material.dart';
import '../models/saving.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';

class SavingsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Saving> _savings = [];
  List<Saving> get savings => _savings;

  double get totalSavings => _savings.where((s) => !s.isCompleted).fold(0.0, (sum, s) => sum + s.amount);

  /// Interest Logic: Principal * (Rate/100) * (Days since start / 365)
  double calculateAccrued(Saving s) {
    final now = DateTime.now();
    int days = now.difference(s.date).inDays;
    if (days <= 0) return 0.0;
    return s.amount * (s.annualInterestRate / 100) * (days / 365);
  }

  Future<void> fetchSavings() async {
    final data = await _storage.queryAll('savings');
    _savings = data.map((s) => Saving.fromMap(s)).toList();
    notifyListeners();
  }

  /// FIXED ADD LOGIC: Explicitly waits for DB and forces a re-fetch
  Future<void> addSaving(Saving s) async {
    final db = await _storage.database;
    await db.insert('savings', s.toMap());
    await fetchSavings(); // THE KEY: Forces the UI to see the data immediately
    SoundService.chaching();
  }

  /// TOP-UP LOGIC: Compounds previous interest and adds new principal
  Future<void> topUp(String id, double topUpAmount) async {
    final idx = _savings.indexWhere((s) => s.id == id);
    if (idx != -1) {
      final s = _savings[idx];
      double lockedInterest = calculateAccrued(s);
      
      final updated = Saving(
        id: s.id,
        description: s.description,
        amount: s.amount + lockedInterest + topUpAmount,
        annualInterestRate: s.annualInterestRate,
        date: DateTime.now(), // Reset cycle to today
        endDate: s.endDate,
        isCompleted: s.isCompleted,
      );

      await _storage.update('savings', updated.toMap(), id);
      await fetchSavings();
      SoundService.chaching();
    }
  }

  Future<void> deleteSaving(String id) async {
    await _storage.delete('savings', id);
    await fetchSavings();
    SoundService.delete();
  }
}