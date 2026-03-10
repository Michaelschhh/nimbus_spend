import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../models/saving.dart';
import '../../providers/savings_provider.dart';
import '../../theme/colors.dart';
import '../common/apple_button.dart';

class GoalCreationSheet extends StatefulWidget {
  const GoalCreationSheet({super.key});

  @override
  State<GoalCreationSheet> createState() => _GoalCreationSheetState();
}

class _GoalCreationSheetState extends State<GoalCreationSheet> {
  final _desc = TextEditingController();
  final _amount = TextEditingController();
  final _rate = TextEditingController();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 365));

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
          const Text("New Saving Goal", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          
          _input(_desc, "Description (e.g. New Car)", LucideIcons.target, false),
          _input(_amount, "Initial Capital", LucideIcons.banknote, true),
          _input(_rate, "Annual Yield %", LucideIcons.trendingUp, true),
          
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              margin: const EdgeInsets.only(top: 15),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: Row(children: [
                const Icon(LucideIcons.calendar, size: 18, color: AppColors.primary),
                const SizedBox(width: 15),
                const Expanded(child: Text("Target Date", style: TextStyle(color: Colors.white))),
                Text(DateFormat('MMM dd, yyyy').format(_targetDate), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),

          const SizedBox(height: 35),
          AppleButton(
            label: "Authorize Goal", 
            onTap: () async {
              if (_desc.text.isEmpty || _amount.text.isEmpty) return;
              
              final goal = Saving(
                description: _desc.text,
                amount: double.tryParse(_amount.text) ?? 0,
                annualInterestRate: double.tryParse(_rate.text) ?? 0,
                date: DateTime.now(),
                endDate: _targetDate,
                isCompleted: false,
              );

              // FIXED LOGIC: Wait for save then close
              await context.read<SavingsProvider>().addSaving(goal);
              if (mounted) Navigator.pop(context);
            }
          ),
        ],
      ),
    );
  }

  void _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: _targetDate, firstDate: DateTime.now(), lastDate: DateTime(2100));
    if (d != null) setState(() => _targetDate = d);
  }

  Widget _input(TextEditingController c, String h, IconData i, bool n) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(15)),
    child: TextField(
      controller: c, keyboardType: n ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(icon: Icon(i, size: 18, color: AppColors.textDim), hintText: h, hintStyle: const TextStyle(color: Colors.white10), border: InputBorder.none),
    ),
  );
}