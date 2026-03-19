import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../models/saving.dart';
import '../../models/expense.dart';
import '../../providers/savings_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/expense_provider.dart';
import '../../utils/life_cost_utils.dart';
import '../../theme/colors.dart';
import '../common/apple_button.dart';
import '../../services/sound_service.dart';
import '../../services/ad_service.dart';

class GoalCreationSheet extends StatefulWidget {
  final Saving? existingSaving;
  const GoalCreationSheet({super.key, this.existingSaving});

  @override
  State<GoalCreationSheet> createState() => _GoalCreationSheetState();
}

class _GoalCreationSheetState extends State<GoalCreationSheet> {
  final _desc = TextEditingController();
  final _amount = TextEditingController();
  final _rate = TextEditingController();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 365));
  String _fundingSource = 'allowance';

  @override
  void initState() {
    super.initState();
    if (widget.existingSaving != null) {
      _desc.text = widget.existingSaving!.description;
      _amount.text = widget.existingSaving!.amount.toString();
      _rate.text = widget.existingSaving!.annualInterestRate.toString();
      _targetDate = widget.existingSaving!.endDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, top: 25, left: 24, right: 24),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(35))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 5, width: 40, decoration: BoxDecoration(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12), borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            Text(widget.existingSaving == null ? "New Saving Goal" : "Edit Saving Goal", style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),
            
            _input(_desc, "Description (e.g. New Car)", LucideIcons.target, false),
            _input(_amount, "Initial Capital", LucideIcons.banknote, true),
            _input(_rate, "Annual Yield %", LucideIcons.trendingUp, true),
            
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                margin: const EdgeInsets.only(top: 15),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(15), border: Border.all(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.05))),
                child: Row(children: [
                  const Icon(LucideIcons.calendar, size: 18, color: AppColors.primary),
                  const SizedBox(width: 15),
                  Expanded(child: Text("Target Date", style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)))),
                  Text(DateFormat('MMM dd, yyyy').format(_targetDate), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ]),
              ),
            ),

            // Funding source for new savings only
            if (widget.existingSaving == null) ...[
              const SizedBox(height: 20),
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
                        DropdownMenuItem(value: 'allowance', child: Text("Debit from Monthly Budget")),
                        DropdownMenuItem(value: 'resources', child: Text("Debit from Available Resources")),
                        DropdownMenuItem(value: 'none', child: Text("No Debit (Track only)")),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _fundingSource = val);
                      },
                    ),
                  ),
                ]),
              ),
            ],

            const SizedBox(height: 35),
            AppleButton(
              label: widget.existingSaving == null ? "Authorize Goal" : "Save Changes", 
              onTap: () async {
                if (_desc.text.isEmpty || _amount.text.isEmpty) return;
                final amount = double.tryParse(_amount.text) ?? 0;
                
                if (widget.existingSaving != null) {
                  final saving = Saving(
                    id: widget.existingSaving!.id,
                    description: _desc.text,
                    amount: amount,
                    annualInterestRate: double.tryParse(_rate.text) ?? 0,
                    date: widget.existingSaving!.date,
                    endDate: _targetDate,
                    isCompleted: widget.existingSaving!.isCompleted,
                  );
                  await context.read<SavingsProvider>().updateSaving(saving);
                  SoundService.success();
                } else {
                  final goal = Saving(
                    description: _desc.text,
                    amount: amount,
                    annualInterestRate: double.tryParse(_rate.text) ?? 0,
                    date: DateTime.now(),
                    endDate: _targetDate,
                    isCompleted: false,
                    fundingSource: _fundingSource,
                  );
                  await context.read<SavingsProvider>().addSaving(goal);
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
                      linkedId: goal.id,
                    );

                    if (_fundingSource == 'allowance') {
                      expProv.addExpense(expense, sProv, skipResourceUpdate: true);
                    } else if (_fundingSource == 'resources') {
                      expProv.addExpense(expense, sProv, skipResourceUpdate: true);
                      sProv.deductFromResources(amount);
                    }
                  }
                }

                final sProv = context.read<SettingsProvider>();
                if (!sProv.settings.isPro) {
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
            ),
          ],
        ),
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
    decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(15)),
    child: TextField(
      controller: c, keyboardType: n ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
      decoration: InputDecoration(icon: Icon(i, size: 18, color: AppColors.textDim), hintText: h, hintStyle: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12)), border: InputBorder.none),
    ),
  );
}