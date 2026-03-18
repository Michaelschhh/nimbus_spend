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
  bool _showHistory = false;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SavingsProvider>();
    final s = context.read<SettingsProvider>().settings;

    // Filter Active Goals (Not matured)
    final active = prov.savings.where((sg) => !sg.isMatured).toList();

    return Scaffold(
      backgroundColor: Colors.black,
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
                  const Text("Wealth", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const MaturedSavingsScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: AppColors.cardBg, shape: BoxShape.circle),
                      child: const Icon(LucideIcons.archive, color: AppColors.primary, size: 20),
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
                bgColor: Colors.white,
                textColor: Colors.black,
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
    return Container(
      width: double.infinity, height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF2C2C2E), Color(0xFF000000)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("NIMBUS PLATINUM", style: TextStyle(color: Colors.white24, letterSpacing: 2, fontSize: 10, fontWeight: FontWeight.bold)),
          const Spacer(),
          const Text("Total Stored Value", style: TextStyle(color: AppColors.textDim, fontSize: 14)),
          const SizedBox(height: 4),
          Text(Formatters.currency(total, cur), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -1)),
          const Spacer(),
          Text(name.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 13, letterSpacing: 1.2)),
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
          color: AppColors.cardBg, 
          borderRadius: BorderRadius.circular(28), 
          border: Border.all(color: AppColors.glassBorder)
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(s.description, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const Icon(LucideIcons.shieldCheck, color: AppColors.success, size: 18),
          ]),
          const SizedBox(height: 20),
          _stat("Principal Sum", Formatters.currency(s.amount, cur)),
          _stat("Accrued Interest", Formatters.currency(accrued, cur), valColor: AppColors.success),
          _stat("1-Year Estimated Yield", Formatters.currency(projected, cur)),
          const Divider(color: Colors.white10, height: 30),
          GestureDetector(
            onTap: () => _showTopUpDialog(context, s, prov),
            child: const Text("Inject Capital +", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          )
        ]),
      ),
    ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _stat(String l, String v, {Color valColor = Colors.white}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: const TextStyle(color: AppColors.textDim)), 
      Text(v, style: TextStyle(color: valColor, fontWeight: FontWeight.bold))
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
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Capital Injection", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: ctrl, keyboardType: TextInputType.number, autofocus: true, 
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Funding Source", style: TextStyle(color: AppColors.textDim, fontSize: 12)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: source,
              isExpanded: true,
              dropdownColor: AppColors.cardBg,
              style: const TextStyle(color: Colors.white),
              underline: Container(height: 1, color: Colors.white24),
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
          }, child: const Text("Authorize", style: TextStyle(color: AppColors.primary))),
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
                color: AppColors.cardBg, 
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.description, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
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
                    bgColor: Colors.white10, 
                    textColor: Colors.white, 
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