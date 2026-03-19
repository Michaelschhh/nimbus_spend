import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/saving.dart';
import '../../models/expense.dart';
import '../../providers/savings_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/expense_provider.dart';
import '../../utils/life_cost_utils.dart';
import '../../theme/colors.dart';
import '../../widgets/common/apple_button.dart';
import '../../services/sound_service.dart';
import '../../services/ad_service.dart';

class AddSavingForm extends StatefulWidget {
  const AddSavingForm({super.key});
  @override
  State<AddSavingForm> createState() => _AddSavingFormState();
}

class _AddSavingFormState extends State<AddSavingForm> {
  final _desc = TextEditingController();
  final _amount = TextEditingController();
  final _rate = TextEditingController();
  String _fundingSource = 'allowance';

  void _submit() async {
    if (_desc.text.isEmpty || _amount.text.isEmpty) return;
    final amount = double.tryParse(_amount.text) ?? 0.0;
    
    final newGoal = Saving(
      description: _desc.text,
      amount: amount,
      annualInterestRate: double.tryParse(_rate.text) ?? 0.0,
      date: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 365)),
      fundingSource: _fundingSource,
    );

    await context.read<SavingsProvider>().addSaving(newGoal);
    SoundService.chaching();

    // Handle funding source debit
    if (amount > 0 && _fundingSource != 'none') {
      final sProv = context.read<SettingsProvider>();
      final expProv = context.read<ExpenseProvider>();
      
      final expense = Expense(
        amount: amount,
        category: 'Savings 💰',
        date: DateTime.now(),
        note: 'Savings: ${_desc.text}',
        lifeCostHours: LifeCostUtils.calculate(amount, sProv.settings.hourlyWage),
        fundingSource: _fundingSource,
        linkedId: newGoal.id,
      );

      if (_fundingSource == 'allowance') {
        // Just log expense, resources already reduced by rollover
        expProv.addExpense(expense, sProv, skipResourceUpdate: true);
      } else if (_fundingSource == 'resources') {
        // Deduct from resources and log expense
        expProv.addExpense(expense, sProv, skipResourceUpdate: true);
        sProv.deductFromResources(amount);
      }
    }
    
    final sProv = context.read<SettingsProvider>();
    if (!sProv.settings.isPro && !sProv.settings.adsRemoved) {
      sProv.incrementAdCounter();
      if (sProv.adClickCounter >= 2) {
        AdService.showInterstitialAd(() {
          sProv.resetAdCounter();
          if (mounted) Navigator.pop(context);
        });
        return;
      }
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, top: 25, left: 24, right: 24),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 5, width: 40, decoration: BoxDecoration(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12), borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            Text("Initiate Wealth Goal", style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),
            _input(_desc, "Goal Name", LucideIcons.target, false),
            _input(_amount, "Initial Capital", LucideIcons.banknote, true),
            _input(_rate, "Annual Interest Rate %", LucideIcons.trendingUp, true),

            // Funding source
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(15)),
              child: Row(children: [
                const Icon(LucideIcons.wallet, size: 18, color: AppColors.textDim),
                const SizedBox(width: 15),
                Expanded(
                  child: DropdownButton<String>(
                    value: _fundingSource,
                    isExpanded: true,
                    dropdownColor: Theme.of(context).cardColor,
                    style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'allowance', child: Text("Monthly Budget")),
                      DropdownMenuItem(value: 'resources', child: Text("Available Resources")),
                      DropdownMenuItem(value: 'none', child: Text("No Debit (Track Only)")),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _fundingSource = val);
                    },
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 35),
            AppleButton(label: "Authorize Goal", onTap: _submit),
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String h, IconData i, bool n) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(15)),
    child: TextField(
      controller: c, keyboardType: n ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
      decoration: InputDecoration(icon: Icon(i, size: 18, color: AppColors.textDim), hintText: h, border: InputBorder.none),
    ),
  );
}