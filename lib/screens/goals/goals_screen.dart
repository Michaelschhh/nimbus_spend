import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'dart:ui';
import '../../providers/goals_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/goal.dart';
import '../../models/expense.dart';
import '../../utils/life_cost_utils.dart';
import '../../utils/formatters.dart';
import '../../theme/colors.dart';
import '../../widgets/forms/add_goal_form.dart';
import '../../widgets/common/apple_button.dart';
import '../../services/sound_service.dart';

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
    final goalProv = context.watch<GoalsProvider>();
    final s = context.read<SettingsProvider>().settings;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),
                const Text("Goals", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1)),
                const Spacer(),
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                    builder: (_) => const AddGoalForm(),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: AppColors.cardBg, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.plus, color: AppColors.primary, size: 20),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Text("${goalProv.activeGoals.length} active • ${goalProv.completedGoals.length} achieved",
                  style: const TextStyle(color: AppColors.textDim, fontSize: 14)),
              const SizedBox(height: 30),

              if (goalProv.goals.isEmpty)
                _emptyState()
              else
                ...goalProv.goals.map((g) => _goalCard(context, g, s, goalProv)),

              const SizedBox(height: 140),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(children: [
          Icon(LucideIcons.target, color: Colors.white.withOpacity(0.1), size: 48),
          const SizedBox(height: 16),
          const Text("No goals yet", style: TextStyle(color: AppColors.textDim)),
        ]),
      ),
    );
  }

  Widget _goalCard(BuildContext context, Goal g, dynamic s, GoalsProvider prov) {
    final progress = g.targetAmount > 0 ? (g.currentAmount / g.targetAmount).clamp(0.0, 1.0) : 0.0;
    final remaining = (g.targetAmount - g.currentAmount).clamp(0.0, g.targetAmount);
    final hoursLeft = s.hourlyWage > 0 ? remaining / s.hourlyWage : 0.0;

    return GestureDetector(
      onLongPress: () => _showBlurMenu(context, g, prov),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: g.isCompleted ? AppColors.success.withOpacity(0.15) : Colors.white.withOpacity(0.04)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(g.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
            Icon(g.isCompleted ? LucideIcons.checkCircle : LucideIcons.target,
                color: g.isCompleted ? AppColors.success : AppColors.lifeColor, size: 20),
          ]),
          const SizedBox(height: 16),
          LinearPercentIndicator(
            lineHeight: 8, padding: EdgeInsets.zero,
            percent: progress,
            backgroundColor: Colors.white.withOpacity(0.06),
            progressColor: g.isCompleted ? AppColors.success : AppColors.lifeColor,
            barRadius: const Radius.circular(10),
            animation: true,
          ),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("${(progress * 100).toStringAsFixed(0)}%",
                style: TextStyle(color: g.isCompleted ? AppColors.success : AppColors.lifeColor, fontWeight: FontWeight.bold, fontSize: 13)),
            Text("${Formatters.currency(g.currentAmount, s.currency)} / ${Formatters.currency(g.targetAmount, s.currency)}",
                style: const TextStyle(color: AppColors.textDim, fontSize: 12)),
          ]),
          if (!g.isCompleted && hoursLeft > 0) ...[
            const SizedBox(height: 8),
            Text("${hoursLeft.toStringAsFixed(1)} work hours to reach",
                style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
          ],
        ]),
      ),
    );
  }

  void _showBlurMenu(BuildContext context, Goal g, GoalsProvider prov) {
    final sProv = context.read<SettingsProvider>();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "GoalOptions",
      pageBuilder: (ctx, a1, a2) => Material(
        type: MaterialType.transparency,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardBg, borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(g.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 6),
                Text("${(g.currentAmount / g.targetAmount * 100).clamp(0, 100).toStringAsFixed(0)}% complete",
                    style: const TextStyle(color: AppColors.textDim, fontSize: 14)),
                const SizedBox(height: 30),
                if (!g.isCompleted) ...[
                  AppleButton(label: "Fund from Allowance", onTap: () {
                    Navigator.pop(ctx);
                    _showFundDialog(g, 'allowance', prov, sProv);
                  }),
                  const SizedBox(height: 12),
                  AppleButton(label: "Fund from Resources", bgColor: AppColors.primary, textColor: Colors.white, onTap: () {
                    Navigator.pop(ctx);
                    _showFundDialog(g, 'resources', prov, sProv);
                  }),
                  const SizedBox(height: 12),
                ],
                AppleButton(label: "Delete Goal", isDestructive: true, onTap: () {
                  prov.deleteGoal(g.id);
                  SoundService.delete();
                  Navigator.pop(ctx);
                }),
                const SizedBox(height: 12),
                AppleButton(label: "Cancel", bgColor: Colors.white10, textColor: Colors.white, onTap: () => Navigator.pop(ctx)),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  void _showFundDialog(Goal g, String source, GoalsProvider prov, SettingsProvider sProv) {
    final ctrl = TextEditingController();
    final remaining = g.targetAmount - g.currentAmount;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.cardBg,
      title: const Text("Add Funds", style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: ctrl, keyboardType: TextInputType.number, autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: Formatters.currency(remaining, sProv.settings.currency),
          hintStyle: const TextStyle(color: Colors.white24),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: AppColors.textDim))),
        TextButton(onPressed: () {
          final val = double.tryParse(ctrl.text) ?? 0;
          if (val <= 0) return;
          prov.updateGoalProgress(g.id, val);
          if (source == 'allowance') {
            final expense = Expense(
              amount: val,
              category: 'Goals 🎯',
              date: DateTime.now(),
              note: 'Goal: ${g.name}',
              lifeCostHours: LifeCostUtils.calculate(val, sProv.settings.hourlyWage),
            );
            context.read<ExpenseProvider>().addExpense(expense, sProv);
          } else {
            sProv.deductFromResources(val);
          }
          Navigator.pop(ctx);
        }, child: const Text("Fund", style: TextStyle(color: AppColors.primary))),
      ],
    ));
  }
}
