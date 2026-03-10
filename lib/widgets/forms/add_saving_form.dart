import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/saving.dart';
import '../../providers/savings_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/common/apple_button.dart';

class AddSavingForm extends StatefulWidget {
  const AddSavingForm({super.key});
  @override
  State<AddSavingForm> createState() => _AddSavingFormState();
}

class _AddSavingFormState extends State<AddSavingForm> {
  final _desc = TextEditingController();
  final _amount = TextEditingController();
  final _rate = TextEditingController();

  void _submit() async {
    if (_desc.text.isEmpty || _amount.text.isEmpty) return;
    
    final newGoal = Saving(
      description: _desc.text,
      amount: double.tryParse(_amount.text) ?? 0.0,
      annualInterestRate: double.tryParse(_rate.text) ?? 0.0,
      date: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 365)),
    );

    // FIXED: Explicitly awaiting the provider before closing
    await context.read<SavingsProvider>().addSaving(newGoal);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, top: 25, left: 24, right: 24),
      decoration: const BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 5, width: 40, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 25),
          const Text("Initiate Wealth Goal", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          _input(_desc, "Goal Name", LucideIcons.target, false),
          _input(_amount, "Initial Capital", LucideIcons.banknote, true),
          _input(_rate, "Annual Interest Rate %", LucideIcons.trendingUp, true),
          const SizedBox(height: 35),
          AppleButton(label: "Authorize Goal", onTap: _submit),
        ],
      ),
    );
  }

  Widget _input(TextEditingController c, String h, IconData i, bool n) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(15)),
    child: TextField(
      controller: c, keyboardType: n ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(icon: Icon(i, size: 18, color: AppColors.textDim), hintText: h, border: InputBorder.none),
    ),
  );
}