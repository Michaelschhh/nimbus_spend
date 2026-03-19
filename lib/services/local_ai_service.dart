import '../models/expense.dart';

class LocalAIService {
  /// Analyzes the last 30 days of expenses to provide heuristic-based insights.
  static List<String> generateInsights(List<Expense> expenses, double monthlyBudget, double hourlyWage, double totalSpentThisMonth) {
    if (expenses.isEmpty) {
      return ["Start logging expenses to get personalized AI insights."];
    }

    final insights = <String>[];
    final now = DateTime.now();

    // PACING LOGIC
    final remainingBudget = monthlyBudget - totalSpentThisMonth;
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = lastDayOfMonth - now.day;
    final daysPassed = now.day;

    if (daysPassed > 0) {
      final currentBurnRate = totalSpentThisMonth / daysPassed;
      
      if (remainingBudget <= 0) {
         insights.add("🚨 You have exhausted your allowance for the month! Avoid further spending.");
      } else if (daysRemaining > 0) {
         final safeBurnRate = remainingBudget / daysRemaining;
         if (currentBurnRate > safeBurnRate * 1.5) {
            insights.add("🔥 High Velocity Warning: You are spending \$${currentBurnRate.toStringAsFixed(0)}/day. Safe limit is \$${safeBurnRate.toStringAsFixed(0)}/day. Slow down!");
         } else if (currentBurnRate < safeBurnRate * 0.8) {
            insights.add("🌱 Great pacing! You are safely under your daily limit with \$${remainingBudget.toStringAsFixed(0)} left for the next $daysRemaining days.");
         } else {
            insights.add("⚖️ You are pacing well, right on track to finish the month safely.");
         }
      } else if (daysRemaining == 0 && remainingBudget > 0) {
         insights.add("🎉 Last day of the month! You have successfully secured \$${remainingBudget.toStringAsFixed(0)} in surplus!");
      }
    }

    final recentExpenses = expenses.where((e) => now.difference(e.date).inDays <= 30).toList();
    if (recentExpenses.isNotEmpty) {
      final Map<String, double> categoryTotals = {};
      double totalRecentSpent = 0;

      for (var e in recentExpenses) {
        if (e.fundingSource == 'allowance') {
          categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
          totalRecentSpent += e.amount;
        }
      }

      String topCategory = '';
      double maxSpent = 0;
      categoryTotals.forEach((cat, amount) {
        if (amount > maxSpent) {
          maxSpent = amount;
          topCategory = cat;
        }
      });

      if (maxSpent > 0) {
        final percentOfBudget = (maxSpent / monthlyBudget) * 100;
        if (percentOfBudget > 40) {
          insights.add("⚠️ You spent ${percentOfBudget.toStringAsFixed(0)}% of your budget on $topCategory. Consider cutting back.");
        }
      }

      if (hourlyWage > 0 && totalRecentSpent > 0) {
        final totalHours = totalRecentSpent / hourlyWage;
        if (totalHours > 40) {
          insights.add("⏳ You traded ${totalHours.toStringAsFixed(0)} hours of your life for recent purchases. Was it worth it?");
        }
      }

      final dailyTx = recentExpenses.length / 30;
      if (dailyTx > 3) {
        insights.add("💳 You are making over 3 transactions a day. Try to consolidate purchases.");
      }
    }

    if (insights.isEmpty) {
      insights.add("🌟 Your spending habits look balanced and healthy.");
    }

    return insights;
  }
}
