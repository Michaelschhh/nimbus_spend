import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/goals_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/formatters.dart';
import '../../theme/colors.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<GoalsProvider>().fetchGoals());
  }

  @override
  Widget build(BuildContext context) {
    final goalsProv = context.watch<GoalsProvider>();
    final settings = context.read<SettingsProvider>().settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Financial Goals",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: goalsProv.goals.length,
        itemBuilder: (context, index) {
          final goal = goalsProv.goals[index];
          final progress = (goal.currentAmount / goal.targetAmount).clamp(
            0.0,
            1.0,
          );

          double hoursLeft = 0;
          if (settings.hourlyWage > 0) {
            final remaining = goal.targetAmount - goal.currentAmount;
            final rawHours = remaining / settings.hourlyWage;
            hoursLeft = rawHours < 0 ? 0 : rawHours;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        goal.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(LucideIcons.target, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 15),
                  LinearPercentIndicator(
                    lineHeight: 12.0,
                    percent: progress,
                    backgroundColor: Colors.grey.shade200,
                    progressColor: AppColors.primary,
                    barRadius: const Radius.circular(10),
                    animation: true,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${(progress * 100).toStringAsFixed(0)}% Complete"),
                      Text(
                        "${Formatters.currency(goal.targetAmount, settings.currency)} Target",
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  Text(
                    "Work needed to reach: ${hoursLeft.toStringAsFixed(1)} hours",
                    style: const TextStyle(
                      color: AppColors.lifeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().slideX(begin: 0.1, delay: (index * 100).ms);
        },
      ),
    );
  }
}
