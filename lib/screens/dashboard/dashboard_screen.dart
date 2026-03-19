import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';

import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/colors.dart';
import '../../utils/formatters.dart';
import '../../utils/life_cost_utils.dart';
import '../../widgets/forms/add_expense_form.dart';
import '../../widgets/common/apple_button.dart';
import '../../widgets/common/ad_placements.dart';
import '../../services/sound_service.dart';
import '../../services/local_ai_service.dart';
import '../../models/expense.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exp = context.watch<ExpenseProvider>();
    final sProv = context.watch<SettingsProvider>();
    final s = sProv.settings;
    
    double left = s.monthlyBudget - exp.totalSpentThisMonth;
    bool isOver = left < 0;

    return Scaffold(
      
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _header(context, s.name, s.availableResources, s.currency),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: BannerAdSpace(),
              ),
              const SizedBox(height: 10),

              // THE MAIN ALLOWANCE CARD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _mainCard(context, left, s.currency, isOver),
              ),
              const SizedBox(height: 30),

              // AI INSIGHTS SECTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text("AI Insights", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), letterSpacing: -0.5)),
              ),
              const SizedBox(height: 15),
              _buildInsightsCarousel(context, exp.expenses, s.monthlyBudget, s.hourlyWage, exp.totalSpentThisMonth),
              
              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text("Transactions", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), letterSpacing: -0.5)),
              ),
              const SizedBox(height: 15),
              
              if (exp.expenses.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Wallet Empty", style: TextStyle(color: AppColors.textDim))))
              else
                ...exp.expenses.take(10).map((e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _item(context, e, exp, sProv, s.currency),
                )),
              
              const SizedBox(height: 140),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, String name, double resource, String cur) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sProv = context.read<SettingsProvider>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Available Resources", style: TextStyle(color: AppColors.textDim, fontSize: 13, fontWeight: FontWeight.bold)),
          Text(Formatters.currency(resource, cur), style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, letterSpacing: -1)),
        ]),
        Row(children: [
          GestureDetector(
            onTap: () => sProv.setDarkMode(!isDark),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
              ),
              child: Icon(isDark ? LucideIcons.moon : LucideIcons.sun, size: 18, color: isDark ? Colors.white : Colors.black),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(backgroundColor: Theme.of(context).cardColor, child: Text(name.isNotEmpty ? name[0] : "U", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
        ]),
      ],
    );
  }

  Widget _mainCard(BuildContext context, double left, String cur, bool isOver) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(32),
        border: Border.all(color: isOver ? AppColors.danger.withOpacity(0.5) : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.05)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("MONTHLY ALLOWANCE", style: TextStyle(color: isOver ? AppColors.danger : AppColors.textDim, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          GestureDetector(
            onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => const AddExpenseForm()),
            child: Icon(LucideIcons.plusCircle, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), size: 28),
          ),
        ]),
        const SizedBox(height: 12),
        Text(Formatters.currency(left, cur), 
          style: TextStyle(fontSize: 46, fontWeight: FontWeight.w700, color: isOver ? AppColors.danger : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), letterSpacing: -2)),
        const SizedBox(height: 15),
        Text(isOver ? "DANGER: Budget Exceeded" : "Current Cycle Active", 
          style: TextStyle(color: isOver ? AppColors.danger : AppColors.success, fontWeight: FontWeight.bold, fontSize: 11)),
      ]),
    );
  }

  Widget _item(BuildContext context, dynamic e, ExpenseProvider prov, SettingsProvider sProv, String cur) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showAppleMenu(context, e, prov, sProv),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(22)),
        child: Row(children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.category, style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.w600)),
              if (sProv.settings.hourlyWage > 0 && e.lifeCostHours != null && e.lifeCostHours > 0)
                Text("Cost: ${e.lifeCostHours.toStringAsFixed(1)} hours of life", style: const TextStyle(color: AppColors.lifeColor, fontSize: 11, fontWeight: FontWeight.bold)),
            ]
          )),
          Text(Formatters.currency(e.amount, cur), style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.bold)),
        ]),
      ),
    ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  void _showAppleMenu(BuildContext context, dynamic e, ExpenseProvider prov, SettingsProvider sProv) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      pageBuilder: (ctx, anim1, anim2) => Material(
        type: MaterialType.transparency,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(32), border: Border.all(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(e.category, style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  if (e.category != 'Bills 📄' && e.category != 'Debts 💳' && e.category != 'Goals 🎯' && e.category != 'Savings 💰') ...[
                    AppleButton(label: "Edit Entry", onTap: () {
                      Navigator.pop(ctx);
                      showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => AddExpenseForm(existingExpense: e));
                    }),
                    const SizedBox(height: 12),
                  ],
                  if (e.category != 'Bills 📄' && e.category != 'Debts 💳' && e.category != 'Goals 🎯' && e.category != 'Savings 💰' && e.category != 'Subscriptions 💎')
                    AppleButton(label: "Delete Payment", isDestructive: true, onTap: () {
                      prov.deleteExpense(e.id, sProv);
                      SoundService.delete();
                      Navigator.pop(ctx);
                    }),
                  const SizedBox(height: 12),
                    AppleButton(label: "Cancel", bgColor: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12), textColor: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), onTap: () => Navigator.pop(ctx)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsCarousel(BuildContext context, List<dynamic> expenses, double budget, double wage, double totalSpentThisMonth) {
    // Cast list back for service
    final eList = expenses.cast<Expense>();
    final insights = LocalAIService.generateInsights(eList, budget, wage, totalSpentThisMonth);

    return SizedBox(
      height: 110,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          scrollDirection: Axis.horizontal,
          itemCount: insights.length,
          itemBuilder: (context, index) {
            final isWarning = insights[index].contains('⚠️') || insights[index].contains('Cost') || insights[index].contains('hours');
            return Container(
              width: 280,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isWarning ? AppColors.warning.withOpacity(0.3) : AppColors.primary.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(children: [
                    Icon(LucideIcons.sparkles, color: isWarning ? AppColors.warning : AppColors.primary, size: 14),
                    const SizedBox(width: 8),
                    Text("NIMBUS AI", style: TextStyle(color: isWarning ? AppColors.warning : AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  ]),
                  const SizedBox(height: 10),
                  Text(insights[index], style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontSize: 13, height: 1.3), maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}