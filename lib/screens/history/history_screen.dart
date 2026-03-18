import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/forms/add_expense_form.dart';
import '../../widgets/common/ad_placements.dart';
import '../../services/sound_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expProv = context.watch<ExpenseProvider>();
    final sProv = context.watch<SettingsProvider>();
    final cur = sProv.settings.currency;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Text("History", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: BannerAdSpace(),
            ),
            Expanded(
              child: expProv.expenses.isEmpty 
              ? const Center(child: Text("No records yet", style: TextStyle(color: AppColors.textDim)))
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 120),
                  itemCount: expProv.expenses.length,
                  itemBuilder: (context, index) {
                    final e = expProv.expenses[index];
                    return _buildExpenseItem(context, index, e, expProv, sProv, cur);
                  },
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItem(BuildContext context, int index, dynamic e, ExpenseProvider expProv, SettingsProvider sProv, String cur) {
    return Dismissible(
      key: Key(e.id),
      direction: (e.category == 'Bills 📄' || e.category == 'Debts 💳' || e.category == 'Goals 🎯' || e.category == 'Savings 💰' || e.category == 'Subscriptions 💎')
          ? DismissDirection.none 
          : DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(22)),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        expProv.deleteExpense(e.id, sProv);
        SoundService.delete();
      },
      child: GestureDetector(
        // FIXED: Correct delete logic with both arguments
        onTap: () => _showBlurMenu(context, e, expProv, sProv),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(22)),
          child: Row(children: [
            Expanded(child: Text(e.category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
            Text(Formatters.currency(e.amount, cur), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1);
  }

  void _showBlurMenu(BuildContext context, dynamic e, ExpenseProvider prov, SettingsProvider sProv) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(e.category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            if (e.category != 'Bills 📄' && e.category != 'Debts 💳' && e.category != 'Goals 🎯' && e.category != 'Savings 💰')
              TextButton(onPressed: () {
                Navigator.pop(ctx);
                showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => AddExpenseForm(existingExpense: e));
              }, child: const Text("Edit", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
            if (e.category != 'Bills 📄' && e.category != 'Debts 💳' && e.category != 'Goals 🎯' && e.category != 'Savings 💰' && e.category != 'Subscriptions 💎')
              TextButton(onPressed: () {
                prov.deleteExpense(e.id, sProv);
                SoundService.delete();
                Navigator.pop(ctx);
              }, child: const Text("Delete", style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}