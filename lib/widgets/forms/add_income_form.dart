import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/income.dart';
import '../../providers/income_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/colors.dart';
import '../../services/sound_service.dart';
import '../../utils/responsive.dart';
import '../common/apple_button.dart';

class AddIncomeForm extends StatefulWidget {
  final Income? existingIncome;
  const AddIncomeForm({super.key, this.existingIncome});

  @override
  State<AddIncomeForm> createState() => _AddIncomeFormState();
}

class _AddIncomeFormState extends State<AddIncomeForm> {
  late TextEditingController _amount;
  late TextEditingController _source;
  late TextEditingController _note;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(text: widget.existingIncome?.amount.toString() ?? "");
    _source = TextEditingController(text: widget.existingIncome?.source ?? "");
    _note = TextEditingController(text: widget.existingIncome?.note ?? "");
    _selectedDate = widget.existingIncome?.date ?? DateTime.now();
  }

  Future<void> _submit() async {
    final double? val = double.tryParse(_amount.text);
    if (val == null || val <= 0 || _source.text.isEmpty) return;

    final sProv = context.read<SettingsProvider>();
    final iProv = context.read<IncomeProvider>();
    final eProv = context.read<ExpenseProvider>();

    final income = Income(
      amount: val,
      source: _source.text,
      date: _selectedDate,
      note: _note.text,
    );

    await iProv.addIncome(income, sProv, eProv);
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
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 5, width: 40, decoration: BoxDecoration(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12), borderRadius: BorderRadius.circular(10))),
            SizedBox(height: 25),
            Text("Log Income Deposit", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _amount,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(border: InputBorder.none, hintText: "0.00"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _source,
              decoration: InputDecoration(
                labelText: "Source (e.g., Sold Item, Gift)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 15),
            ListTile(
              title: const Text("Date"),
              subtitle: Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
              trailing: const Icon(LucideIcons.calendar),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (d != null) setState(() => _selectedDate = d);
              },
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _note,
              decoration: InputDecoration(
                labelText: "Note (Optional)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 30),
            AppleButton(label: "Add to Resources", onTap: _submit),
          ],
        ),
      ),
    );
  }
}
