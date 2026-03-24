import '../models/expense.dart';
import '../models/ai_insight.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LocalAIService {
  /// Analyzes the last 30 days of expenses to provide heuristic-based insights.
  static List<AIInsight> generateInsights(List<Expense> expenses, double monthlyBudget, double hourlyWage, double totalSpentThisMonth) {
    if (expenses.isEmpty) {
      return [AIInsight(title: "Empty Ledger", body: "Start logging expenses to get personalized AI insights.", icon: LucideIcons.album)];
    }

    final insights = <AIInsight>[];
    final now = DateTime.now();

    // PACING LOGIC
    final remainingBudget = monthlyBudget - totalSpentThisMonth;
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = lastDayOfMonth - now.day;
    final daysPassed = now.day;

    if (daysPassed > 0) {
      final currentBurnRate = totalSpentThisMonth / daysPassed;
      
      if (remainingBudget <= 0) {
         insights.add(AIInsight(
           title: "Budget Exhausted",
           body: "You have exhausted your allowance for the month! Avoid further spending.",
           icon: LucideIcons.alertTriangle
         ));
      } else if (daysRemaining > 0) {
         final safeBurnRate = remainingBudget / daysRemaining;
         if (currentBurnRate > safeBurnRate * 1.5) {
            insights.add(AIInsight(
              title: "High Velocity",
              body: "You are spending \$${currentBurnRate.toStringAsFixed(0)}/day. Safe limit is \$${safeBurnRate.toStringAsFixed(0)}/day. Slow down!",
              icon: LucideIcons.flame
            ));
         } else if (currentBurnRate < safeBurnRate * 0.8) {
            insights.add(AIInsight(
              title: "Great Pacing",
              body: "You are safely under your daily limit with \$${remainingBudget.toStringAsFixed(0)} left for the next $daysRemaining days.",
              icon: LucideIcons.sprout
            ));
         } else {
            insights.add(AIInsight(
              title: "On Track",
              body: "You are pacing well, right on track to finish the month safely.",
              icon: LucideIcons.scale
            ));
         }
      } else if (daysRemaining == 0 && remainingBudget > 0) {
         insights.add(AIInsight(
           title: "Month Secured",
           body: "Last day of the month! You have successfully secured \$${remainingBudget.toStringAsFixed(0)} in surplus!",
           icon: LucideIcons.partyPopper
         ));
      }
    }

    final recentExpenses = expenses.where((e) => now.difference(e.date).inDays <= 30).toList();
    if (recentExpenses.isNotEmpty) {
      final Map<String, double> categoryTotals = {};
      double totalRecentSpent = 0;

      int weekendTx = 0;
      double weekendSp = 0;
      double weekdaySp = 0;

      for (var e in recentExpenses) {
        if (e.fundingSource == 'allowance') {
          categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
          totalRecentSpent += e.amount;
          
          if (e.date.weekday == DateTime.saturday || e.date.weekday == DateTime.sunday) {
            weekendTx++;
            weekendSp += e.amount;
          } else {
            weekdaySp += e.amount;
          }
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

      if (maxSpent > 0 && monthlyBudget > 0) {
        final percentOfBudget = (maxSpent / monthlyBudget) * 100;
        if (percentOfBudget > 40) {
          insights.add(AIInsight(
            title: "Category Warning",
            body: "You spent ${percentOfBudget.toStringAsFixed(0)}% of your budget on $topCategory. Consider cutting back.",
            icon: LucideIcons.alertCircle
          ));
        }
      }

      if (hourlyWage > 0 && totalRecentSpent > 0) {
        final totalHours = totalRecentSpent / hourlyWage;
        if (totalHours > 40) {
          insights.add(AIInsight(
            title: "Time Exchanged",
            body: "You traded ${totalHours.toStringAsFixed(0)} hours of your life for recent purchases. Was it worth it?",
            icon: LucideIcons.hourglass
          ));
        }
      }

      final dailyTx = recentExpenses.length / 30;
      if (dailyTx > 3) {
        insights.add(AIInsight(
          title: "High Frequency",
          body: "You are making over 3 transactions a day. Try to consolidate purchases.",
          icon: LucideIcons.creditCard
        ));
      }

      // Weekend Warrior check
      if (weekendSp > (weekdaySp * 1.5) && weekendSp > 0) {
        insights.add(AIInsight(
          title: "Weekend Spender",
          body: "You spend significantly more on weekends than during the week. Watch out for impulse buys!",
          icon: LucideIcons.umbrella
        ));
      }

      // Subscription Creep check
      double recurringTotal = recentExpenses.where((e) => e.isRecurring).fold(0.0, (sum, e) => sum + e.amount);
      if (recurringTotal > (monthlyBudget * 0.25) && monthlyBudget > 0) {
        insights.add(AIInsight(
          title: "Subscription Creep",
          body: "Over 25% of your monthly budget is consumed by recurring payments. Time to audit your subscriptions!",
          icon: LucideIcons.repeat,
          actionLabel: "Audit Subscriptions",
          route: "/subscriptions"
        ));
      }

      // Zero-Sum Streak check - only show if user has at least 7 days of history
      final firstExpenseDate = expenses.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b);
      final accountAgeDays = now.difference(firstExpenseDate).inDays;
      
      if (accountAgeDays >= 7) {
        int zeroSumDays = 0;
        for (int i = 1; i <= 7; i++) {
          final d = now.subtract(Duration(days: i));
          double spentOnDay = recentExpenses.where((e) => e.date.year == d.year && e.date.month == d.month && e.date.day == d.day).fold(0.0, (sum, e) => sum + e.amount);
          if (spentOnDay == 0) {
            zeroSumDays++;
          } else {
            break;
          }
        }
        
        if (zeroSumDays >= 3) {
          insights.add(AIInsight(
            title: "Frosty Finances",
            body: "You've gone $zeroSumDays consecutive days without spending a dime! Incredible self-control.",
            icon: LucideIcons.snowflake
          ));
        }
      }
    }

    if (insights.isEmpty) {
      insights.add(AIInsight(
        title: "Healthy Habits",
        body: "Your spending habits look balanced and healthy.",
        icon: LucideIcons.star
      ));
    }

    return insights;
  }
}
