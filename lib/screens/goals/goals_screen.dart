import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import '../../widgets/common/ad_placements.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});
  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  int _selectedTab = 0; // 0 = Active, 1 = Matured
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
                  child: Icon(LucideIcons.arrowLeft, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), size: 22),
                ),
                const SizedBox(width: 16),
                Text("Goals", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), letterSpacing: -1)),
                const Spacer(),
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                    builder: (_) => const AddGoalForm(),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.plus, color: AppColors.primary, size: 20),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(
                children: [
                  _tabBtn("Active", 0, goalProv.activeGoals.length),
                  const SizedBox(width: 12),
                  _tabBtn("Matured", 1, goalProv.completedGoals.length),
                ],
              ),
              const SizedBox(height: 16),
              const BannerAdSpace(),

              if ((_selectedTab == 0 && goalProv.activeGoals.isEmpty) || 
                  (_selectedTab == 1 && goalProv.completedGoals.isEmpty))
                _emptyState()
              else if (_selectedTab == 0)
                ...goalProv.activeGoals.map((g) => _goalCard(context, g, s, goalProv))
              else
                ...goalProv.completedGoals.map((g) => _goalCard(context, g, s, goalProv)),

              const SizedBox(height: 140),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabBtn(String title, int index, int count) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12)),
        ),
        child: Text("$title ($count)", style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textDim, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(children: [
          Icon(LucideIcons.target, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.1), size: 48),
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
      onTap: () => _showBlurMenu(context, g, prov),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: g.isCompleted ? AppColors.success.withOpacity(0.15) : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.04)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(g.name, style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.bold, fontSize: 16))),
            Icon(g.isCompleted ? LucideIcons.checkCircle : LucideIcons.target,
                color: g.isCompleted ? AppColors.success : AppColors.lifeColor, size: 20),
          ]),
          const SizedBox(height: 16),
          LinearPercentIndicator(
            lineHeight: 8, padding: EdgeInsets.zero,
            percent: progress,
            backgroundColor: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.06),
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
    ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
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
                color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(30),
                border: Border.all(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12)),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(g.name, style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 6),
                Text("${(g.currentAmount / g.targetAmount * 100).clamp(0, 100).toStringAsFixed(0)}% complete",
                    style: const TextStyle(color: AppColors.textDim, fontSize: 14)),
                const SizedBox(height: 30),
                if (!g.isCompleted) ...[
                  AppleButton(label: "Add Funds", onTap: () {
                    Navigator.pop(ctx);
                    _showFundDialog(g, prov, sProv);
                  }),
                  const SizedBox(height: 12),
                ],
                AppleButton(label: "Edit Goal", onTap: () {
                  Navigator.pop(ctx);
                  showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => AddGoalForm(existingGoal: g));
                }),
                const SizedBox(height: 12),
                AppleButton(label: "Delete Goal", isDestructive: true, onTap: () {
                  prov.deleteGoal(g.id);
                  context.read<ExpenseProvider>().deleteExpenseByLinkedId(g.id, sProv);
                  SoundService.delete();
                  Navigator.pop(ctx);
                }),
                const SizedBox(height: 12),
                AppleButton(label: "Cancel", bgColor: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12), textColor: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), onTap: () => Navigator.pop(ctx)),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  void _showFundDialog(Goal g, GoalsProvider prov, SettingsProvider sProv) {
    final ctrl = TextEditingController();
    String source = 'allowance';
    final remaining = g.targetAmount - g.currentAmount;
    
    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text("Add Funds", style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: ctrl, keyboardType: TextInputType.number, autofocus: true,
              style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
              decoration: InputDecoration(
                hintText: Formatters.currency(remaining, sProv.settings.currency),
                hintStyle: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26))),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Funding Source", style: TextStyle(color: AppColors.textDim, fontSize: 12)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: source,
              isExpanded: true,
              dropdownColor: Theme.of(context).cardColor,
              style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
              underline: Container(height: 1, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26)),
              items: const [
                DropdownMenuItem(value: 'allowance', child: Text("Monthly Budget (Expense)")),
                DropdownMenuItem(value: 'resources', child: Text("Available Resources")),
                DropdownMenuItem(value: 'none', child: Text("None (Update only)")),
              ],
              onChanged: (val) {
                if (val != null) setState(() => source = val);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: AppColors.textDim))),
          TextButton(onPressed: () {
            final val = double.tryParse(ctrl.text) ?? 0;
            if (val <= 0) return;
            prov.updateGoalProgress(g.id, val);
            SoundService.chaching();
            if (source == 'allowance') {
              final expense = Expense(
                amount: val,
                category: 'Goals 🎯',
                date: DateTime.now(),
                note: 'Goal: ${g.name}',
                lifeCostHours: LifeCostUtils.calculate(val, sProv.settings.hourlyWage),
                linkedId: g.id,
                fundingSource: 'allowance',
              );
              context.read<ExpenseProvider>().addExpense(expense, sProv, skipResourceUpdate: true);
            } else if (source == 'resources') {
              final expense = Expense(
                amount: val,
                category: 'Goals 🎯',
                date: DateTime.now(),
                note: 'Goal: ${g.name}',
                lifeCostHours: 0,
                linkedId: g.id,
                fundingSource: 'resources',
              );
              context.read<ExpenseProvider>().addExpense(expense, sProv, skipResourceUpdate: false);
            }
            Navigator.pop(ctx);
          }, child: const Text("Fund", style: TextStyle(color: AppColors.primary))),
        ],
      )
    ));
  }
}
