import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/colors.dart';
import '../../utils/life_cost_utils.dart';
import '../../services/sound_service.dart';
import '../../services/ad_service.dart';
import '../common/apple_button.dart';
import '../common/custom_switch.dart';
import '../../utils/responsive.dart';

class AddExpenseForm extends StatefulWidget {
  final Expense? existingExpense;
  const AddExpenseForm({super.key, this.existingExpense});

  @override
  State<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<AddExpenseForm> {
  late TextEditingController _amount;
  late TextEditingController _note;
  late String _cat;
  late bool _isRec;
  late String _freq;
  String _fundingSource = 'allowance';

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(text: widget.existingExpense?.amount.toString() ?? "");
    _note = TextEditingController(text: widget.existingExpense?.note ?? "");
    _cat = widget.existingExpense?.category ?? "Shopping";
    _isRec = widget.existingExpense?.isRecurring ?? false;
    _freq = widget.existingExpense?.recurringFrequency ?? "Monthly";
  }

  // Category-aware thresholds for AI insight
  double _getWarningThreshold(String category) {
    switch (category) {
      case 'Health':
      case 'Food':
        return 0.40; // 40% — essential spending, higher tolerance
      case 'Transport':
        return 0.30; // 30%
      default:
        return 0.15; // 15% — Shopping, Bills, etc.
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'Health': return 'health expenses';
      case 'Food': return 'food';
      case 'Transport': return 'transportation';
      case 'Shopping': return 'shopping';
      case 'Bills': return 'bills';
      default: return 'this expense';
    }
  }

  Future<void> _submit() async {
    String sanitized = _amount.text.replaceAll(',', '').replaceAll(' ', '');
    final double? val = double.tryParse(sanitized);
    if (val == null || val <= 0) return;

    final sProv = context.read<SettingsProvider>();
    final eProv = context.read<ExpenseProvider>();

    // 1. Forced Reflection Timer
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Theme.of(context).primaryColor),
            const SizedBox(height: 20),
            Text("Analyzing budget impact...", style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context);

    // 2. Percentage-based AI Insight (varies by category)
    if (widget.existingExpense == null) {
      final resources = sProv.settings.availableResources;
      final allowanceRemaining = sProv.settings.monthlyBudget - eProv.totalSpentThisMonth;
      
      double baseline = (_fundingSource == 'allowance') ? allowanceRemaining : resources;
      String sourceLabel = (_fundingSource == 'allowance') ? "monthly budget" : "available resources";

      if (baseline > 0) {
        final percentage = (val / baseline * 100);
        final threshold = _getWarningThreshold(_cat);

        if (val / baseline >= threshold) {
          final shouldProceed = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: AppColors.warning)),
              title: Row(
                children: [
                   const Icon(LucideIcons.brainCircuit, color: AppColors.warning),
                   const SizedBox(width: 8),
                   Text("AI Insight", style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))),
                ],
              ),
              content: Text(
                "This ${_getCategoryLabel(_cat)} costs ${percentage.toStringAsFixed(1)}% of your $sourceLabel. Do you really need this right now?",
                style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87), height: 1.4),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("Cancel", style: TextStyle(color: AppColors.textDim)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text("Yes, proceed", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );

          if (shouldProceed != true) return;
        }
      }
    }

    final expense = Expense(
      id: widget.existingExpense?.id,
      amount: val,
      category: _cat,
      date: widget.existingExpense?.date ?? DateTime.now(),
      isRecurring: _isRec,
      recurringFrequency: _isRec ? _freq : null,
      lifeCostHours: LifeCostUtils.calculate(val, sProv.settings.hourlyWage),
      note: _note.text,
      fundingSource: _fundingSource,
    );

    if (widget.existingExpense != null) {
      eProv.updateExpense(expense, widget.existingExpense!, sProv);
    } else {
      // Handle funding source
      if (_fundingSource == 'allowance') {
        // Monthly Budget: just log expense, resources NOT touched (budget is pre-allocated)
        eProv.addExpense(expense, sProv, skipResourceUpdate: true);
      } else if (_fundingSource == 'resources') {
        // Available Resources: log expense + deduct from resources
        eProv.addExpense(expense, sProv, skipResourceUpdate: true);
        sProv.deductFromResources(val);
      } else {
        // None: just log it, no resource change
        eProv.addExpense(expense, sProv, skipResourceUpdate: true);
      }

      // --- Seamless Interstitial Injection ---
      if (!sProv.settings.isPro && !sProv.settings.adsRemoved) {
        sProv.incrementAdCounter();
        if (sProv.adClickCounter >= 2) {
           AdService.showInterstitialAd(() {
             sProv.resetAdCounter();
             if (mounted) Navigator.pop(context);
           });
           SoundService.success();
           return;
        }
      }
    }

    SoundService.success();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + Responsive.sp(30, context),
        top: Responsive.sp(20, context),
        left: Responsive.sp(24, context),
        right: Responsive.sp(24, context),
      ),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.vertical(top: Radius.circular(Responsive.sp(35, context)))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 5, width: 40, decoration: BoxDecoration(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12), borderRadius: BorderRadius.circular(10))),
            SizedBox(height: Responsive.sp(25, context)),
            Text(_isRec ? "Authorize Subscription" : "Authorize Payment", 
              style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontSize: Responsive.fs(17, context), fontWeight: FontWeight.bold)),
            
            TextField(
              controller: _amount,
              autofocus: widget.existingExpense == null,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: Responsive.fs(54, context), fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), letterSpacing: -2),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(border: InputBorder.none, hintText: "0.00"),
            ),
            
            // RECURRING TOGGLE (Apple Style)
            Container(
              padding: EdgeInsets.all(Responsive.sp(16, context)),
              decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12))),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Recurring Payment", style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.w600, fontSize: Responsive.fs(14, context))),
                      CustomSwitch(value: _isRec, onChanged: (v) => setState(() => _isRec = v)),
                    ],
                  ),
                  if (_isRec) ...[
                    Divider(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12), height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ["Daily", "Weekly", "Monthly", "Yearly"].map((f) => GestureDetector(
                        onTap: () => setState(() => _freq = f),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: Responsive.sp(12, context), vertical: Responsive.sp(8, context)),
                          decoration: BoxDecoration(color: _freq == f ? Theme.of(context).primaryColor : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                          child: Text(f, style: TextStyle(color: _freq == f ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black) : AppColors.textDim, fontSize: Responsive.fs(11, context), fontWeight: FontWeight.bold)),
                        ),
                      )).toList(),
                    )
                  ]
                ],
              ),
            ),

            // FUNDING SOURCE SELECTOR
            if (widget.existingExpense == null) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12))),
                child: Row(children: [
                  const Icon(LucideIcons.wallet, size: 18, color: AppColors.textDim),
                  const SizedBox(width: 12),
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
                        DropdownMenuItem(value: 'none', child: Text("None (Track Only)")),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _fundingSource = val);
                      },
                    ),
                  ),
                ]),
              ),
            ],
            
            const SizedBox(height: 25),
            _categoryGrid(),
            const SizedBox(height: 35),

            AppleButton(label: "Confirm Authorization", onTap: _submit),
          ],
        ),
      ),
    );
  }

  Widget _categoryGrid() {
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: ["Shopping", "Food", "Transport", "Bills", "Health"].map((c) => GestureDetector(
        onTap: () => setState(() => _cat = c),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: _cat == c ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black) : Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(15), border: Border.all(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12))),
          child: Text(c, style: TextStyle(color: _cat == c ? Theme.of(context).scaffoldBackgroundColor : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.bold)),
        ),
      )).toList(),
    );
  }
}