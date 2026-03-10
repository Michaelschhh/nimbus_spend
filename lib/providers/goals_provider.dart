import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../services/storage_service.dart';

class GoalsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Goal> _goals = [];

  List<Goal> get goals => _goals;

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

  Future<void> updateGoalProgress(String id, double amount) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      final updated = Goal(
        id: _goals[index].id,
        name: _goals[index].name,
        targetAmount: _goals[index].targetAmount,
        currentAmount: _goals[index].currentAmount + amount,
        deadline: _goals[index].deadline,
        isCompleted:
            (_goals[index].currentAmount + amount) >=
            _goals[index].targetAmount,
      );
      await _storage.update('goals', updated.toMap(), id);
      _goals[index] = updated;
      notifyListeners();
    }
  }
}
