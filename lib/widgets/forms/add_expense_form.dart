import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/colors.dart';
import '../../utils/life_cost_utils.dart';
import '../../services/sound_service.dart';
import '../common/apple_button.dart';

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
  final double _hours = 0.0;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(text: widget.existingExpense?.amount.toString() ?? "");
    _note = TextEditingController(text: widget.existingExpense?.note ?? "");
    _cat = widget.existingExpense?.category ?? "Shopping";
    _isRec = widget.existingExpense?.isRecurring ?? false;
    _freq = widget.existingExpense?.recurringFrequency ?? "Monthly";
  }

  void _submit() {
    String sanitized = _amount.text.replaceAll(',', '').replaceAll(' ', '');
    final double? val = double.tryParse(sanitized);
    if (val == null || val <= 0) return;

    final sProv = context.read<SettingsProvider>();
    final eProv = context.read<ExpenseProvider>();

    final expense = Expense(
      id: widget.existingExpense?.id,
      amount: val,
      category: _cat,
      date: widget.existingExpense?.date ?? DateTime.now(),
      isRecurring: _isRec,
      recurringFrequency: _isRec ? _freq : null,
      lifeCostHours: LifeCostUtils.calculate(val, sProv.settings.hourlyWage),
      note: _note.text,
    );

    if (widget.existingExpense != null) {
      eProv.updateExpense(expense, widget.existingExpense!.amount, sProv);
    } else {
      eProv.addExpense(expense, sProv);
    }

    SoundService.success();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, top: 20, left: 24, right: 24),
      decoration: const BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 5, width: 40, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            Text(_isRec ? "Authorize Subscription" : "Authorize Payment", 
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            
            TextField(
              controller: _amount,
              autofocus: widget.existingExpense == null,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 54, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -2),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(border: InputBorder.none, hintText: "0.00"),
            ),
            
            // RECURRING TOGGLE (Apple Style)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.white10)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Recurring Payment", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      Switch.adaptive(value: _isRec, activeColor: AppColors.primary, onChanged: (v) => setState(() => _isRec = v)),
                    ],
                  ),
                  if (_isRec) ...[
                    const Divider(color: Colors.white10, height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ["Daily", "Weekly", "Monthly", "Yearly"].map((f) => GestureDetector(
                        onTap: () => setState(() => _freq = f),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: _freq == f ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                          child: Text(f, style: TextStyle(color: _freq == f ? Colors.white : AppColors.textDim, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      )).toList(),
                    )
                  ]
                ],
              ),
            ),
            
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
          decoration: BoxDecoration(color: _cat == c ? Colors.white : Colors.black, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.white10)),
          child: Text(c, style: TextStyle(color: _cat == c ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
        ),
      )).toList(),
    );
  }
}