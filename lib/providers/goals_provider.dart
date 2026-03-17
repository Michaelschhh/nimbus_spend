import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../services/storage_service.dart';

class GoalsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Goal> _goals = [];

  List<Goal> get goals => _goals;
  List<Goal> get activeGoals => _goals.where((g) => !g.isCompleted).toList();
  List<Goal> get completedGoals => _goals.where((g) => g.isCompleted).toList();

  Future<void> fetchGoals() async {
    final data = await _storage.queryAll('goals');
    _goals = data.map((g) => Goal.fromMap(g)).toList();
    notifyListeners();
  }

  Future<void> addGoal(Goal goal) async {
    await _storage.insert('goals', goal.toMap());
    _goals.add(goal);
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    await _storage.delete('goals', id);
    await fetchGoals();
  }

  Future<void> updateGoalProgress(String id, double amount) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      final g = _goals[index];
      final newAmount = g.currentAmount + amount;
      final updated = Goal(
        id: g.id,
        name: g.name,
        targetAmount: g.targetAmount,
        currentAmount: newAmount,
        deadline: g.deadline,
        isCompleted: newAmount >= g.targetAmount,
        completedDate: newAmount >= g.targetAmount ? DateTime.now() : null,
      );
      await _storage.update('goals', updated.toMap(), id);
      _goals[index] = updated;
      notifyListeners();
    }
  }

  void clear() {
    _goals = [];
    notifyListeners();
  }
}
