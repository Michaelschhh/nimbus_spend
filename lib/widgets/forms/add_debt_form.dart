import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/debt.dart';
import '../../providers/debt_provider.dart';
import '../../theme/colors.dart';

class AddDebtForm extends StatefulWidget {
  const AddDebtForm({super.key});

  @override
  State<AddDebtForm> createState() => _AddDebtFormState();
}

class _AddDebtFormState extends State<AddDebtForm> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  bool _isOwedToMe = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24, left: 24, right: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_isOwedToMe ? "Money Owed to Me" : "Money I Owe",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 15),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Is someone owing you?", style: TextStyle(color: Colors.white)),
            value: _isOwedToMe,
            onChanged: (v) => setState(() => _isOwedToMe = v),
            activeColor: AppColors.primary,
          ),
          const SizedBox(height: 8),
          _field(_nameController, "Person Name"),
          const SizedBox(height: 12),
          _field(_amountController, "Amount", isNum: true),
          const SizedBox(height: 12),
          _field(_descController, "Description (Optional)"),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                if (_nameController.text.isEmpty) return;
                final debt = Debt(
                  personName: _nameController.text,
                  amount: double.tryParse(_amountController.text) ?? 0,
                  description: _descController.text,
                  date: DateTime.now(),
                  isOwedToMe: _isOwedToMe,
                );
                context.read<DebtProvider>().addDebt(debt);
                Navigator.pop(context);
              },
              child: const Text("Add Debt Entry",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, {bool isNum = false}) {
    return TextField(
      controller: c,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: AppColors.textDim),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.white24)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors.primary)),
      ),
    );
  }
}
