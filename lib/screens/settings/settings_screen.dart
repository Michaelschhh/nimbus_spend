import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/settings_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/common/currency_picker_modal.dart';

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
            const SizedBox(height: 35),
            
            _editCard(context, "Identity", s.name, (v) => prov.completeOnboarding(v, s.monthlyBudget, s.hourlyWage, s.currency)),
            _editCard(context, "Allocation", s.monthlyBudget.toString(), (v) => prov.completeOnboarding(s.name, double.tryParse(v) ?? 1000, s.hourlyWage, s.currency)),
            
            GestureDetector(
              onTap: () => _showCurrencyPicker(context, prov),
              child: _staticCard("Standard Currency", s.currency, LucideIcons.globe),
            ),
            
            const SizedBox(height: 60),
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

  Widget _editCard(BuildContext context, String l, String v, Function(String) onSave) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l, style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
          Text(v, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        ])),
        const Icon(LucideIcons.edit3, color: AppColors.primary, size: 18),
      ]),
    );
  }

  Widget _staticCard(String l, String v, IconData i) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [Icon(i, color: AppColors.primary, size: 20), const SizedBox(width: 15), Expanded(child: Text(l)), Text(v, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))]),
    );
  }

  void _confirmPurge(BuildContext context, SettingsProvider prov) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.cardBg,
      title: const Text("Purge Data"),
      content: const Text("Wiping all financial data. App will reset."),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
        TextButton(onPressed: () { prov.clearAllData(); Navigator.pop(ctx); }, child: const Text("PURGE", style: TextStyle(color: AppColors.danger))),
      ],
    ));
  }
}