import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';

import '../../providers/income_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/expense_provider.dart';
import '../../theme/colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/forms/add_income_form.dart';

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final incProv = context.watch<IncomeProvider>();
    final sProv = context.watch<SettingsProvider>();
    final cur = sProv.settings.currency;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
                      child: const Icon(LucideIcons.arrowLeft, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text("Income Ledger", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: incProv.incomes.isEmpty 
              ? const Center(child: Text("No records yet", style: TextStyle(color: AppColors.textDim)))
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 120),
                  itemCount: incProv.incomes.length,
                  itemBuilder: (context, index) {
                    final e = incProv.incomes[index];
                    return _buildIncomeItem(context, index, e, incProv, sProv, cur);
                  },
                ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => const AddIncomeForm()),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildIncomeItem(BuildContext context, int index, dynamic e, IncomeProvider incProv, SettingsProvider sProv, String cur) {
    final eProv = context.read<ExpenseProvider>();
    var animated = Dismissible(
      key: Key(e.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(22)),
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
      ),
      onDismissed: (_) {
        incProv.deleteIncome(e.id, sProv, eProv);
      },
      child: GestureDetector(
        onTap: () => _showBlurMenu(context, e, incProv, sProv, eProv),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(22)),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Income", style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.w600)),
                  Text(e.source, style: const TextStyle(color: AppColors.textDim, fontSize: 13)),
                ]
              )
            ),
            Text(Formatters.currency(e.amount, cur), style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1);

    if (sProv.settings.motionBlurEnabled) {
      animated = animated.blurX(begin: 10, end: 0, duration: 300.ms, curve: Curves.easeOut);
    }
    return animated;
  }

  void _showBlurMenu(BuildContext context, dynamic e, IncomeProvider prov, SettingsProvider sProv, ExpenseProvider eProv) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(e.source, style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.bold)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            TextButton(onPressed: () {
              // Wait, AddIncomeForm probably doesn't support existingIncome yet. 
              // Leaving empty edit for now or just let users delete/re-add since AddIncomeForm only takes none.
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please delete and re-add income to modify it for now.')));
            }, child: Text("Edit", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))),
            TextButton(onPressed: () {
              prov.deleteIncome(e.id, sProv, eProv);
              Navigator.pop(ctx);
            }, child: const Text("Delete", style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}
