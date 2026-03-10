import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../providers/savings_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/forms/goal_creation_sheet.dart';
import '../../widgets/common/apple_button.dart';
import '../../services/sound_service.dart';

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

    // Filter Active vs Matured Goals
    final active = prov.savings.where((sg) => !sg.isCompleted).toList();
    final matured = prov.savings.where((sg) => sg.isCompleted).toList();

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
                    onTap: () => setState(() => _showHistory = !_showHistory),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: AppColors.cardBg, shape: BoxShape.circle),
                      child: Icon(_showHistory ? LucideIcons.checkCircle : LucideIcons.history, color: AppColors.primary, size: 20),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),

              // 1. THE NIMBUS PLATINUM ATM CARD
              _buildATMCard(prov.totalSavings, s.currency, s.name),
              const SizedBox(height: 30),

              if (!_showHistory) ...[
                const Text("Good job! Your vault is growing.", 
                  style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 35),
                
                // NEW GOAL BUTTON
                AppleButton(
                  label: "Start New Goal", 
                  onTap: () => _openAdd(context),
                  bgColor: Colors.white,
                  textColor: Colors.black,
                ),
                
                const SizedBox(height: 35),
                ...active.map((sg) => _savingCard(context, sg, s.currency, prov)),
              ] else ...[
                const Text("Matured History", style: TextStyle(color: AppColors.textDim, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 20),
                ...matured.map((sg) => _savingCard(context, sg, s.currency, prov)),
              ],
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
      onLongPress: () => _showBlurMenu(context, s, prov),
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
    );
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
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      title: const Text("Capital Injection"),
      content: TextField(controller: ctrl, keyboardType: TextInputType.number, autofocus: true, style: const TextStyle(color: Colors.white)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
        TextButton(onPressed: () {
          double val = double.tryParse(ctrl.text) ?? 0;
          if (val > 0) prov.topUp(s.id, val);
          Navigator.pop(ctx);
        }, child: const Text("Authorize")),
      ],
    ));
  }

  // ... existing imports ...

  void _showBlurMenu(BuildContext context, dynamic s, SavingsProvider prov) {
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
                    label: "Delete Goal", 
                    isDestructive: true, 
                    onTap: () {
                      prov.deleteSaving(s.id);
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