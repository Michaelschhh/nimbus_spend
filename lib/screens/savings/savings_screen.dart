import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../providers/savings_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/forms/goal_creation_sheet.dart';
import '../../widgets/common/apple_button.dart';
import '../../services/sound_service.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense.dart';
import '../../utils/life_cost_utils.dart';
import '../../widgets/common/ad_placements.dart';
import 'matured_savings_screen.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});
  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  final bool _showHistory = false;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SavingsProvider>();
    final s = context.read<SettingsProvider>().settings;

    // Filter Active Goals (Not matured)
    final active = prov.savings.where((sg) => !sg.isMatured).toList();

    return Scaffold(
      
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Wealth", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const MaturedSavingsScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
                      child: Icon(LucideIcons.archive, color: Theme.of(context).primaryColor, size: 20),
                    ),
                  )
                ],
              ),
              const BannerAdSpace(),

              // 1. THE NIMBUS PLATINUM ATM CARD
              _buildATMCard(prov.totalSavings, s.currency, s.name),
              const SizedBox(height: 30),

              if (active.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text("Start your wealth journey below.", style: TextStyle(color: AppColors.textDim)),
                  ),
                ),

              // NEW GOAL BUTTON
              AppleButton(
                label: "Start New Goal", 
                onTap: () => _openAdd(context),
                bgColor: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                textColor: Theme.of(context).scaffoldBackgroundColor 
              ),
              
              const SizedBox(height: 35),
              ...active.map((sg) => _savingCard(context, sg, s.currency, prov)),
              const SizedBox(height: 140),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildATMCard(double total, String cur, String name) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity, height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: isDark 
              ? [Theme.of(context).primaryColor.withOpacity(0.3), Color(0xFF000000)]
              : [const Color(0xFFF2F2F7), const Color(0xFFE5E5EA)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("NIMBUS PLATINUM", style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, letterSpacing: 2, fontSize: 10, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text("Total Stored Value", style: TextStyle(color: isDark ? AppColors.textDim : Colors.black54, fontSize: 14)),
          const SizedBox(height: 4),
          Text(Formatters.currency(total, cur), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -1)),
          const Spacer(),
          Text(name.toUpperCase(), style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _savingCard(BuildContext context, dynamic s, String cur, SavingsProvider prov) {
    double accrued = prov.calculateAccrued(s);
    double projected = s.amount + (s.amount * (s.annualInterestRate / 100));

    return GestureDetector(
      onTap: () => _showBlurMenu(context, s, prov),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, 
          borderRadius: BorderRadius.circular(28), 
          border: Border.all(color: AppColors.glassBorder)
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(s.description, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))),
            const Icon(LucideIcons.shieldCheck, color: AppColors.success, size: 18),
          ]),
          const SizedBox(height: 20),
          _stat(context, "Principal Sum", Formatters.currency(s.amount, cur)),
          _stat(context, "Accrued Interest", Formatters.currency(accrued, cur), valColor: AppColors.success),
          _stat(context, "1-Year Estimated Yield", Formatters.currency(projected, cur)),
          Divider(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12), height: 30),
          GestureDetector(
            onTap: () => _showTopUpDialog(context, s, prov),
            child: Text("Inject Capital +", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
          )
        ]),
      ),
    ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _stat(BuildContext context, String l, String v, {Color? valColor}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: const TextStyle(color: AppColors.textDim)), 
      Text(v, style: TextStyle(color: valColor ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.bold))
    ]),
  );

  void _openAdd(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent, 
      builder: (ctx) => const GoalCreationSheet()
    );
  }

  void _showTopUpDialog(BuildContext context, dynamic s, SavingsProvider prov) {
    final ctrl = TextEditingController();
    String source = 'allowance';
    final sProv = context.read<SettingsProvider>();
    
    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text("Capital Injection", style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: ctrl, keyboardType: TextInputType.number, autofocus: true, 
              style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26))),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
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
            double val = double.tryParse(ctrl.text) ?? 0;
            if (val > 0) {
              prov.topUp(s.id, val);
              SoundService.chaching();
              if (source != 'none') {
                final expense = Expense(
                  amount: val,
                  category: 'Savings 💰',
                  date: DateTime.now(),
                  note: 'Savings Top-up: ${s.description}',
                  lifeCostHours: LifeCostUtils.calculate(val, sProv.settings.hourlyWage),
                  fundingSource: source,
                  linkedId: s.id,
                );
                
                if (source == 'allowance') {
                  context.read<ExpenseProvider>().addExpense(expense, sProv, skipResourceUpdate: true);
                } else if (source == 'resources') {
                  context.read<ExpenseProvider>().addExpense(expense, sProv, skipResourceUpdate: true);
                  sProv.deductFromResources(val);
                }
              }
            }
            Navigator.pop(ctx);
          }, child: Text("Authorize", style: TextStyle(color: Theme.of(context).primaryColor))),
        ],
      )
    ));
  }

  // ... existing imports ...

  void _showBlurMenu(BuildContext context, dynamic s, SavingsProvider prov) {
    final sProv = context.read<SettingsProvider>();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "GoalOptions",
      pageBuilder: (ctx, a1, a2) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Material( // THIS REMOVES THE YELLOW LINES
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, 
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.description, style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 30),
                  AppleButton(
                    label: "Add Funds", 
                    onTap: () {
                      Navigator.pop(ctx);
                      _showTopUpDialog(context, s, prov);
                    }
                  ),
                  const SizedBox(height: 12),
                  AppleButton(
                    label: "Edit Goal", 
                    onTap: () {
                      Navigator.pop(ctx);
                      showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => GoalCreationSheet(existingSaving: s));
                    }
                  ),
                  const SizedBox(height: 12),
                  AppleButton(
                    label: "Delete Goal", 
                    isDestructive: true, 
                    onTap: () {
                      prov.deleteSaving(s.id, sProv, context.read<ExpenseProvider>());
                      Navigator.pop(ctx);
                    }
                  ),
                  const SizedBox(height: 12),
                  AppleButton(
                    label: "Cancel", 
                    bgColor: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12), 
                    textColor: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), 
                    onTap: () => Navigator.pop(ctx)
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}