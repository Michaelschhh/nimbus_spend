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
import '../../services/pdf_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expProv = context.watch<ExpenseProvider>();
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("History", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))),
                  IconButton(
                    icon: Icon(Icons.print, color: Theme.of(context).primaryColor),
                    onPressed: () async {
                      // Step 1: Pick start date
                      final startDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().subtract(const Duration(days: 30)),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        helpText: 'Select starting date for summary',
                      );
                      if (startDate == null) return;

                      // Step 2: Generate PDF
                      final filePath = await PdfService.generateTaxSummary(
                        allTransactions: expProv.expenses,
                        sProv: sProv,
                        startDate: startDate,
                      );

                      // Step 3: Show confirmation dialog
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            title: Row(children: [
                              Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 28),
                              const SizedBox(width: 12),
                              const Expanded(child: Text("PDF Generated")),
                            ]),
                            content: Text(
                              "Your tax summary has been saved to:\n\n$filePath",
                              style: const TextStyle(fontSize: 13, height: 1.5),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text("Okay", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
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
    var animated = Dismissible(
      key: Key(e.id),
      direction: (e.category == 'Bills 📄' || e.category == 'Debts 💳' || e.category == 'Goals 🎯' || e.category == 'Savings 💰' || e.category == 'Subscriptions 💎' || e.category == 'Income 💰')
          ? DismissDirection.none 
          : DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(22)),
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
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
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(22)),
          child: Row(children: [
            Expanded(child: Text(e.category, style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.w600))),
            Text(Formatters.currency(e.amount, cur), style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1);

    if (sProv.settings.motionBlurEnabled) {
      animated = animated.blurX(begin: 10, end: 0, duration: 300.ms, curve: Curves.easeOut);
    }
    return animated;
  }

  void _showBlurMenu(BuildContext context, dynamic e, ExpenseProvider prov, SettingsProvider sProv) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(e.category, style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.bold)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            if (e.category != 'Bills 📄' && e.category != 'Debts 💳' && e.category != 'Goals 🎯' && e.category != 'Savings 💰' && e.category != 'Income 💰')
              TextButton(onPressed: () {
                Navigator.pop(ctx);
                showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => AddExpenseForm(existingExpense: e));
              }, child: Text("Edit", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))),
            if (e.category != 'Bills 📄' && e.category != 'Debts 💳' && e.category != 'Goals 🎯' && e.category != 'Savings 💰' && e.category != 'Subscriptions 💎' && e.category != 'Income 💰')
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