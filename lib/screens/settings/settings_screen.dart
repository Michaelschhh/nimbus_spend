import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/settings_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/bills_provider.dart';
import '../../providers/debt_provider.dart';
import '../../providers/goals_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/common/currency_picker_modal.dart';
import '../../widgets/common/custom_switch.dart';
import '../../services/sound_service.dart';
import '../../services/iap_service.dart';
import '../../widgets/common/ad_placements.dart';
import 'salary_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SettingsProvider>();
    final s = prov.settings;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text("Settings", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
            const BannerAdSpace(),
            const SizedBox(height: 15),
            
            _editCard(context, "Identity", s.name, LucideIcons.user, (v) => prov.updateProfile(v, s.monthlyBudget, s.hourlyWage, s.currency)),
            _editCard(context, "Monthly Allocation", s.monthlyBudget.toStringAsFixed(0), LucideIcons.wallet, (v) => prov.updateProfile(s.name, double.tryParse(v) ?? 1000, s.hourlyWage, s.currency)),
            _editCard(context, "Available Resources", s.availableResources.toStringAsFixed(0), LucideIcons.landmark, (v) {
              final val = double.tryParse(v);
              if (val != null) prov.updateAvailableResources(val);
            }),
            _editCard(context, "Hourly Wage", s.hourlyWage.toStringAsFixed(0), LucideIcons.clock, (v) => prov.updateProfile(s.name, s.monthlyBudget, double.tryParse(v) ?? 20, s.currency)),
            
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const SalarySettingsScreen())),
              child: _staticCard("Salary", s.isSalaryEarner ? "Active" : "Disabled", LucideIcons.briefcase),
            ),
            
            GestureDetector(
              onTap: () => _showCurrencyPicker(context, prov),
              child: _staticCard("Standard Currency", s.currency, LucideIcons.globe),
            ),
            
            const SizedBox(height: 25),
            const Text("Preferences", style: TextStyle(color: AppColors.textDim, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _soundCard(context, prov),
            
            const SizedBox(height: 60),
            
            // Remove Ads
            if (!s.isPro)
              GestureDetector(
                onTap: () => IAPService.buyRemoveAds(),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.2), Colors.purple.withOpacity(0.15)]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(LucideIcons.shieldOff, color: AppColors.primary, size: 18),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text("Remove Ads", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                      Text(IAPService.priceString, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                    ])),
                    const Icon(LucideIcons.chevronRight, color: AppColors.primary, size: 16),
                  ]),
                ),
              ),
            
            GestureDetector(
              onTap: () => IAPService.restorePurchases(),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(20)),
                child: const Row(children: [
                  Icon(LucideIcons.refreshCw, color: AppColors.textDim, size: 18),
                  SizedBox(width: 14),
                  Expanded(child: Text("Restore Purchases", style: TextStyle(fontSize: 15, color: AppColors.textDim))),
                ]),
              ),
            ),

            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _confirmPurge(context, prov),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                child: const Center(child: Text("PURGE ALL DATA", style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, SettingsProvider prov) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => CurrencyPickerModal(onSelect: (code) {
        prov.completeOnboarding(prov.settings.name, prov.settings.monthlyBudget, prov.settings.hourlyWage, code);
        Navigator.pop(context);
      }),
    );
  }

  Widget _editCard(BuildContext context, String l, String v, IconData icon, Function(String) onSave) {
    return GestureDetector(
      onTap: () {
        final ctrl = TextEditingController(text: v);
        showDialog(context: context, builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.cardBg,
          title: Text("Edit $l", style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: const Text("Cancel", style: TextStyle(color: AppColors.textDim))
            ),
            TextButton(
              onPressed: () {
                onSave(ctrl.text);
                Navigator.pop(ctx);
              },
              child: const Text("Save", style: TextStyle(color: AppColors.primary))
            )
          ]
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l, style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
            Text(v, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          ])),
          const Icon(LucideIcons.edit3, color: Colors.white24, size: 16),
        ]),
      ),
    );
  }

  Widget _soundCard(BuildContext context, SettingsProvider prov) {
    // Only import CustomSwitch here if not already imported, but better to import at top
    // Since I'm using multi_replace, I'll add the import at the top too.
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        const Icon(LucideIcons.volume2, color: AppColors.primary, size: 18),
        const SizedBox(width: 14),
        const Expanded(child: Text("App Sounds", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
        TextButton(
          onPressed: () => SoundService.tap(),
          child: const Text("TEST", style: TextStyle(color: AppColors.textDim, fontSize: 12)),
        ),
        const SizedBox(width: 10),
        CustomSwitch(
          value: prov.settings.soundsEnabled,
          onChanged: (val) {
            prov.toggleSounds(val);
            SoundService.setEnabled(val);
          },
        ),
      ]),
    );
  }

  Widget _staticCard(String l, String v, IconData i) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Icon(i, color: AppColors.primary, size: 18),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l, style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
          Text(v, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.success)),
        ])),
        const Icon(LucideIcons.chevronRight, color: Colors.white24, size: 16),
      ]),
    );
  }

  void _confirmPurge(BuildContext context, SettingsProvider prov) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.cardBg,
      title: const Text("Purge Data"),
      content: const Text("Wiping all financial data. App will reset."),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
        TextButton(onPressed: () { 
          prov.clearAllData(); 
          context.read<ExpenseProvider>().clear();
          context.read<BillsProvider>().clear();
          context.read<DebtProvider>().clear();
          context.read<GoalsProvider>().clear();
          context.read<SubscriptionProvider>().clear();
          Navigator.pop(ctx); 
        }, child: const Text("PURGE", style: TextStyle(color: AppColors.danger))),
      ],
    ));
  }
}