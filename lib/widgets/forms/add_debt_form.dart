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
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isOwedToMe ? "Money Owed to Me" : "Money I Owe",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text("Is someone owing you?"),
            value: _isOwedToMe,
            onChanged: (v) => setState(() => _isOwedToMe = v),
            activeThumbColor: AppColors.primary,
          ),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Person Name"),
          ),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: "Amount"),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: "Description (Optional)",
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () {
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
              child: const Text(
                "Add Debt Entry",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
