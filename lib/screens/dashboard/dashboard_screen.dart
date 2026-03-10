import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';

import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/colors.dart';
import '../../utils/formatters.dart';
import '../../utils/life_cost_utils.dart';
import '../../widgets/forms/add_expense_form.dart';
import '../../widgets/common/apple_button.dart';
import '../../services/sound_service.dart';

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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _header(s.name, s.availableResources, s.currency),
              const SizedBox(height: 40),

              // THE MAIN ALLOWANCE CARD
              _mainCard(context, left, s.currency, isOver),
              const SizedBox(height: 40),

              const Text("Transactions", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5)),
              const SizedBox(height: 15),
              
              if (exp.expenses.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Wallet Empty", style: TextStyle(color: AppColors.textDim))))
              else
                ...exp.expenses.take(10).map((e) => _item(context, e, exp, sProv, s.currency)),
              
              const SizedBox(height: 140),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(String name, double resource, String cur) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Available Resources", style: TextStyle(color: AppColors.textDim, fontSize: 13, fontWeight: FontWeight.bold)),
          Text(Formatters.currency(resource, cur), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1)),
        ]),
        CircleAvatar(backgroundColor: AppColors.cardBg, child: Text(name.isNotEmpty ? name[0] : "U", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _mainCard(BuildContext context, double left, String cur, bool isOver) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardBg, borderRadius: BorderRadius.circular(32),
        border: Border.all(color: isOver ? AppColors.danger.withOpacity(0.5) : Colors.white.withOpacity(0.05)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("MONTHLY ALLOWANCE", style: TextStyle(color: isOver ? AppColors.danger : AppColors.textDim, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          GestureDetector(
            onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => const AddExpenseForm()),
            child: const Icon(LucideIcons.plusCircle, color: Colors.white, size: 28),
          ),
        ]),
        const SizedBox(height: 12),
        Text(Formatters.currency(left, cur), 
          style: TextStyle(fontSize: 46, fontWeight: FontWeight.w700, color: isOver ? AppColors.danger : Colors.white, letterSpacing: -2)),
        const SizedBox(height: 15),
        Text(isOver ? "DANGER: Budget Exceeded" : "Current Cycle Active", 
          style: TextStyle(color: isOver ? AppColors.danger : AppColors.success, fontWeight: FontWeight.bold, fontSize: 11)),
      ]),
    );
  }

  Widget _item(BuildContext context, dynamic e, ExpenseProvider prov, SettingsProvider sProv, String cur) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => _showAppleMenu(context, e, prov, sProv),
      onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => AddExpenseForm(existingExpense: e)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(22)),
        child: Row(children: [
          Expanded(child: Text(e.category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
          Text(Formatters.currency(e.amount, cur), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
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
              decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.white10)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(e.category, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  AppleButton(label: "Edit Entry", onTap: () {
                    Navigator.pop(ctx);
                    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => AddExpenseForm(existingExpense: e));
                  }),
                  const SizedBox(height: 12),
                  AppleButton(label: "Delete Payment", isDestructive: true, onTap: () {
                    prov.deleteExpense(e.id, sProv);
                    SoundService.delete();
                    Navigator.pop(ctx);
                  }),
                  const SizedBox(height: 12),
                  AppleButton(label: "Cancel", bgColor: Colors.white10, textColor: Colors.white, onTap: () => Navigator.pop(ctx)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}