import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/badge.dart';
import '../widgets/common/badge_celebration.dart';

class GamificationProvider extends ChangeNotifier {
  int _streak = 0;
  int _spendingScore = 100;
  final List<BadgeModel> _unlockedBadges = [];

  int get streak => _streak;
  int get spendingScore => _spendingScore;
  List<BadgeModel> get unlockedBadges => _unlockedBadges;

  GamificationProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _streak = prefs.getInt('streak') ?? 0;
    _spendingScore = prefs.getInt('spendingScore') ?? 100;
    notifyListeners();
  }

  /// Calculates weekly score based on budget vs actual spending
  void updateScore(double totalSpent, double budget) {
    if (budget <= 0) return;
    double percentage = (totalSpent / budget);

    // Logic: 100 is perfect. For every 1% over budget, lose 1 point.
    if (percentage <= 1.0) {
      _spendingScore = 100;
    } else {
      int penalty = ((percentage - 1.0) * 100).toInt();
      _spendingScore = (100 - penalty).clamp(0, 100);
    }
    _save();
  }

  /// Checks and unlocks badges
  void checkBadges(
    BuildContext context, {
    required int expenseCount,
    required double totalSavings,
    required int completedGoals,
  }) {
    // 🏆 "First Expense"
    if (expenseCount >= 1) {
      _unlock(
        context,
        'first_exp',
        "First Expense",
        "You logged your first transaction!",
        "🏆",
      );
    }

    // 💰 "Saver"
    if (totalSavings > 100) {
      _unlock(
        context,
        'saver',
        "Saver",
        "You've saved your first \$100!",
        "💰",
      );
    }

    // 🎯 "Goal Getter"
    if (completedGoals >= 1) {
      _unlock(
        context,
        'goal_getter',
        "Goal Getter",
        "You reached your first goal!",
        "🎯",
      );
    }
  }

  void _unlock(
    BuildContext context,
    String id,
    String name,
    String desc,
    String emoji,
  ) async {
    if (_unlockedBadges.any((b) => b.id == id)) return;

    final newBadge = BadgeModel(
      id: id,
      name: name,
      description: desc,
      emoji: emoji,
      isUnlocked: true,
    );
    _unlockedBadges.add(newBadge);

    // Show the celebration overlay
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, _, __) => BadgeCelebration(badge: newBadge),
    );

    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streak', _streak);
    await prefs.setInt('spendingScore', _spendingScore);
    notifyListeners();
  }
}
